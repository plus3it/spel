import os

import distro
import pytest
from six.moves import urllib

# Static globals
METADATA_KERNEL = 'http://169.254.169.254/latest/meta-data/kernel-id'
FIPS_DISABLED = set(['true', 'TRUE', '1', 'on'])

# Markers
VIRTUALIZATION_MARKERS = set(['hvm', 'paravirtual'])
PLAT_MARKERS = set(['el7', 'el8'])
FIPS_MARKERS = set(['fips_enabled', 'fips_disabled'])

# Platform-specific globals
PLAT = 'el' + distro.major_version()
FIPS = 'fips_disabled' if os.environ.get('SPEL_DISABLEFIPS') in FIPS_DISABLED \
    else 'fips_enabled'
VIRT = 'hvm'
try:
    urllib.request.urlopen(METADATA_KERNEL)
    VIRT = 'paravirtual'
except urllib.error.URLError:
    pass


def pytest_configure(config):
    config.addinivalue_line(
        "markers", "el7: mark test to run only on el7 platforms"
    )
    config.addinivalue_line(
        "markers", "el8: mark test to run only on el8 platforms"
    )
    config.addinivalue_line(
        "markers", "hvm: mark test to run only on hvm instances"
    )
    config.addinivalue_line(
        "markers", "paravirtual: mark test to run only on paravirtual instances"
    )
    config.addinivalue_line(
        "markers", "fips_enabled: mark test to run only if fips is enabled"
    )
    config.addinivalue_line(
        "markers", "fips_disabled: mark test to run only if fips is disabled"
    )


def pytest_runtest_setup(item):
    if isinstance(item, pytest.Function):
        if not item.get_closest_marker(PLAT):
            if PLAT_MARKERS.intersection(item.keywords):
                pytest.skip('does not run on platform {0}'.format(PLAT))
        if not item.get_closest_marker(VIRT):
            if VIRTUALIZATION_MARKERS.intersection(item.keywords):
                pytest.skip(
                    'does not run on virtualization type {0}'.format(VIRT))
        if not item.get_closest_marker(FIPS):
            if FIPS_MARKERS.intersection(item.keywords):
                pytest.skip(
                    'test incompatible with fips mode, {0}'.format(FIPS))


def pytest_logger_stdoutloggers(item):
    return ['spel_validation']
