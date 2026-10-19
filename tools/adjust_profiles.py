#!/usr/bin/env python3
"""按实际 Bundle ID 校验并写入唯一 Adjust 配置；事件映射开放，token 原样交由 Adjust 处理。"""

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
from pathlib import Path


PROFILE_RESOURCE = "JoyiAdjustProfile.json"
SUMMARY_RESOURCE = "JoyiAdjustProfileSummary.json"
BUNDLE_ID_RE = re.compile(r"[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\Z")


class ProfileError(ValueError):
    pass


def valid_token(value, length):
    return (isinstance(value, str)
            and re.fullmatch(r"[A-Za-z0-9]{%d}" % length, value) is not None)


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            # 不输出 JSON 内容或重复键的值，避免构建日志带出凭据。
            raise ProfileError("duplicate JSON key")
        result[key] = value
    return result


def _reject_constant(_value):
    raise ProfileError("non-standard JSON constant")


def load_profile(profiles_dir, bundle_id):
    if not BUNDLE_ID_RE.fullmatch(bundle_id):
        raise ProfileError("invalid build bundleId")
    filename = bundle_id + ".json"
    try:
        # macOS 默认文件系统不区分大小写；exists() 不能证明文件名精确匹配。
        if filename not in {entry.name for entry in profiles_dir.iterdir() if entry.is_file()}:
            raise ProfileError("matching profile is missing; Adjust disabled, no fallback")
        with (profiles_dir / filename).open(encoding="utf-8") as handle:
            profile = json.load(handle, object_pairs_hook=_unique_object, parse_constant=_reject_constant)
    except (OSError, UnicodeError):
        raise ProfileError("profile cannot be read; Adjust disabled, no fallback") from None
    except json.JSONDecodeError as error:
        raise ProfileError("invalid JSON at line {} column {}".format(error.lineno, error.colno)) from None
    if not isinstance(profile, dict):
        raise ProfileError("profile must be a JSON dictionary")
    if profile.get("bundleId") != bundle_id:
        raise ProfileError("profile bundleId does not match build bundleId; Adjust disabled, no fallback")
    if not valid_token(profile.get("appToken"), 12):
        raise ProfileError("appToken must contain exactly 12 ASCII alphanumeric characters; Adjust disabled, no fallback")
    if not isinstance(profile.get("eventTokens"), dict):
        raise ProfileError("eventTokens must be a JSON dictionary")
    if any(not event for event in profile["eventTokens"]):
        raise ProfileError("eventTokens keys must be nonempty event names")
    if any(not isinstance(token, str) for token in profile["eventTokens"].values()):
        raise ProfileError("eventTokens values must be strings")
    return profile


def _canonical_json(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"), allow_nan=False)


def _fingerprint(value):
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def profile_summary(profile, source_name, configuration):
    event_tokens = profile["eventTokens"]
    return {
        "selected": True,
        "bundleId": profile["bundleId"],
        "sourceProfile": source_name,
        "configuration": configuration,
        "appTokenFingerprint": _fingerprint(profile["appToken"]),
        "eventTokensFingerprint": _fingerprint(_canonical_json(event_tokens)),
        "profileFingerprint": _fingerprint(_canonical_json(profile)),
        "configuredEvents": sorted(event_tokens),
    }


def remove_outputs(resources_dir):
    for name in (PROFILE_RESOURCE, SUMMARY_RESOURCE):
        (resources_dir / name).unlink(missing_ok=True)


def _atomic_json(path, value):
    temp_path = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent,
                                         prefix="." + path.name + ".", delete=False) as handle:
            temp_path = Path(handle.name)
            handle.write(_canonical_json(value) + "\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_path, path)
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)


def _write_resources(resources_dir, summary, profile=None):
    try:
        resources_dir.mkdir(parents=True, exist_ok=True)
        if profile is not None:
            _atomic_json(resources_dir / PROFILE_RESOURCE, profile)
        _atomic_json(resources_dir / SUMMARY_RESOURCE, summary)
    except (OSError, ValueError):
        remove_outputs(resources_dir)
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profiles-dir", required=True, type=Path)
    parser.add_argument("--bundle-id", required=True)
    parser.add_argument("--configuration", required=True)
    parser.add_argument("--resources-dir", type=Path)
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args(argv)
    if not args.check_only and args.resources_dir is None:
        parser.error("--resources-dir is required unless --check-only is used")
    strict = args.configuration != "Debug"
    source_name = args.bundle_id + ".json"
    context = "[AdjustProfiles] bundleId={} profile={} configuration={}".format(
        args.bundle_id, source_name, args.configuration)
    try:
        # 先清旧资源，再选择；切包、切配置和任何失败均不能复用前次凭据。
        if not args.check_only:
            remove_outputs(args.resources_dir)
    except OSError:
        print("error: {} cannot remove stale Adjust resources".format(context), file=sys.stderr)
        return 1
    try:
        profile = load_profile(args.profiles_dir, args.bundle_id)
    except ProfileError as error:
        print("{}: {} {}".format("error" if strict else "warning", context, error), file=sys.stderr)
        if not strict and not args.check_only:
            summary = {"selected": False, "bundleId": args.bundle_id,
                       "sourceProfile": source_name, "configuration": args.configuration,
                       "issues": [str(error)]}
            try:
                _write_resources(args.resources_dir, summary)
            except (OSError, ValueError):
                print("error: {} cannot write disabled Adjust summary".format(context), file=sys.stderr)
                return 1
        return 1 if strict else 0
    print("{} selected".format(context))
    summary = profile_summary(profile, source_name, args.configuration)
    summary["issues"] = []
    if args.check_only:
        return 0
    try:
        _write_resources(args.resources_dir, summary, profile)
    except (OSError, ValueError):
        print("error: {} cannot write Adjust resources".format(context), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
