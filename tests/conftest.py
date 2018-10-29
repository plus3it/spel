import os

import distro
import pytest
from six.moves import urllib

# Static globals
METADATA_KERNEL = 'http://169.254.169.254/latest/meta-data/kernel-id'
FIPS_DISABLED = set(['true', 'TRUE', '1', 'on'])

# Markers
VIRTUALIZATION_MARKERS = set(['hvm', 'paravirutal'])
PLAT_MARKERS = set(['el7'])
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


def pytest_runtest_setup(item):
    if isinstance(item, item.Function):
        if not item.get_marker(PLAT):
            if PLAT_MARKERS.intersection(item.keywords):
                pytest.skip('does not run on platform {0}'.format(PLAT))
        if not item.get_marker(VIRT):
            if VIRTUALIZATION_MARKERS.intersection(item.keywords):
                pytest.skip(
                    'does not run on virtualization type {0}'.format(VIRT))
        if not item.get_marker(FIPS):
            if FIPS_MARKERS.intersection(item.keywords):
                pytest.skip(
                    'test incompatible with fips mode, {0}'.format(FIPS))


def pytest_logger_stdoutloggers(item):
    return ['spel_validation']
