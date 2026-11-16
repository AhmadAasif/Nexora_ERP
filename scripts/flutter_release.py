"""Select a stable SDK and supply its version without Git-based detection."""

import json
from pathlib import Path
import sys


def select_release(manifest, destination):
    release = next(
        item for item in manifest["releases"]
        if item["hash"] == manifest["current_release"]["stable"]
    )
    destination.write_text(json.dumps(release))
    return release["archive"]


def cache_version(release, sdk):
    cache = sdk / "bin/cache"
    version_file = cache / "flutter.version.json"
    version = json.loads(version_file.read_text()) if version_file.exists() else {}
    version.update({
        "frameworkVersion": release["version"],
        "flutterVersion": release["version"],
        "channel": release["channel"],
        "repositoryUrl": "https://github.com/flutter/flutter.git",
        "frameworkRevision": release["hash"],
        "frameworkCommitDate": release["release_date"],
        "engineRevision": (sdk / "bin/internal/engine.version").read_text().strip(),
        "dartSdkVersion": release["dart_sdk_version"],
        "devToolsVersion": version.get("devToolsVersion", ""),
    })
    cache.mkdir(parents=True, exist_ok=True)
    version_file.write_text(json.dumps(version))


if __name__ == "__main__":
    if sys.argv[1] == "select":
        print(select_release(json.load(sys.stdin), Path(sys.argv[2])))
    elif sys.argv[1] == "cache":
        cache_version(json.loads(Path(sys.argv[2]).read_text()), Path(sys.argv[3]))
    else:
        raise SystemExit("Expected select or cache")
