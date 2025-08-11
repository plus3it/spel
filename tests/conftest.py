"""Configuration for pytest."""

import os
import urllib.error
import urllib.request

import distro
import pytest

# Static globals
METADATA_KERNEL = "http://169.254.169.254/latest/meta-data/kernel-id"
FIPS_DISABLED = set(["true", "TRUE", "1", "on"])

# Markers
VIRTUALIZATION_MARKERS = set(["hvm", "paravirtual"])
PLAT_MARKERS = set(["el7", "el8", "el9"])
FIPS_MARKERS = set(["fips_enabled", "fips_disabled"])
AMIUTILS_MARKERS = set(["amiutils_enabled", "amiutils_disabled"])

# Platform-specific globals
PLAT = "el9" if distro.major_version() == "2023" else "el" + distro.major_version()

FIPS = (
    "fips_disabled"
    if os.environ.get("SPEL_DISABLEFIPS") in FIPS_DISABLED
    else "fips_enabled"
)
AMIUTILS = (
    "amiutils_enabled" if os.environ.get("SPEL_AMIUTILSOURCE") else "amiutils_disabled"
)
VIRT = "hvm"
try:
    with urllib.request.urlopen(METADATA_KERNEL):
        VIRT = "paravirtual"
except urllib.error.URLError:
    pass


def pytest_configure(config):
    """Configure pytest."""
    config.addinivalue_line("markers", "el8: mark test to run only on el8 platforms")
    config.addinivalue_line("markers", "el9: mark test to run only on el9 platforms")
    config.addinivalue_line("markers", "hvm: mark test to run only on hvm instances")
    config.addinivalue_line(
        "markers", "paravirtual: mark test to run only on paravirtual instances"
    )
    config.addinivalue_line(
        "markers", "fips_enabled: mark test to run only if fips is enabled"
    )
    config.addinivalue_line(
        "markers", "fips_disabled: mark test to run only if fips is disabled"
    )
    config.addinivalue_line(
        "markers", "amiutils_enabled: mark test to run only if AMI Utils pkgs were used"
    )
    config.addinivalue_line(
        "markers",
        "amiutils_disabled: mark test to run only if AMI Utils pkgs were not used",
    )


def pytest_runtest_setup(item):
    """Configure pytest."""
    if isinstance(item, pytest.Function):
        if not item.get_closest_marker(PLAT):
            if PLAT_MARKERS.intersection(item.keywords):
                pytest.skip(f"does not run on platform {PLAT}")
        if not item.get_closest_marker(VIRT):
            if VIRTUALIZATION_MARKERS.intersection(item.keywords):
                pytest.skip(f"does not run on virtualization type {VIRT}")
        if not item.get_closest_marker(FIPS):
            if FIPS_MARKERS.intersection(item.keywords):
                pytest.skip(f"test incompatible with fips mode, {FIPS}")
        if not item.get_closest_marker(AMIUTILS_MARKERS):
            if AMIUTILS_MARKERS.intersection(item.keywords):
                pytest.skip(f"does not run when ami utils is deselected, {AMIUTILS}")


def pytest_logger_stdoutloggers(item):  # pylint: disable=unused-argument
    """Configure pytest logger."""
    return ["spel_validation"]
