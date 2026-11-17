import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class OwnershipTest(unittest.TestCase):
    def test_repository_has_no_overlap(self):
        result = subprocess.run(
            [sys.executable, "tools/check-ownership.py", "--check", "distro/ownership.json"],
            cwd=ROOT, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("0 solapamientos", result.stdout)

    def test_overlap_fails(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "ownership.json"
            path.write_text(json.dumps({"apt": ["hyprland"], "nix": ["hyprland"]}))
            result = subprocess.run(
                [sys.executable, "tools/check-ownership.py", "--check", str(path)],
                cwd=ROOT, text=True, capture_output=True,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn("solapamiento: hyprland", result.stderr)


if __name__ == "__main__":
    unittest.main()
