def pytest_addoption(parser):
    # parser.addoption("--api-key", action="store", default=None, dest="apikey",)
    # parser.addoption("--api-secret", action="store", default=None, dest="_apisecret")
    parser.addoption("--vpn-server", action="store", default=None, dest="vpnserver")
    parser.addoption("--cis", action="store_true", default=False, help='Run CIS Benchmark')
    parser.addoption("--no-linux",
                     action="store_true",
                     default=False,
                     dest="nolinux",
                     help='When running on Mac/Windows, some components might not work properly. '
                          'This option tells PyTest to ignore those components errors')
    # parser.addoption("--snyk-token", action="store", default=None, dest="snyktoken")


def pytest_generate_tests(metafunc):
    # This is called for every test. Only get/set command line arguments
    # if the argument is specified in the list of test "fixturenames".
    # option_value = metafunc.config.option.apikey
    # if 'apikey' in metafunc.fixturenames and option_value is not None:
    #     metafunc.parametrize("apikey", [option_value])
    #
    # option_value = metafunc.config.option._apisecret
    # if '_apisecret' in metafunc.fixturenames and option_value is not None:
    #     metafunc.parametrize("_apisecret", [option_value])

    # this needs to be optional because if we use the VPN server all the time, we'll fill up all the available IPs
    if 'vpnserver' in metafunc.fixturenames:
        metafunc.parametrize("vpnserver", [metafunc.config.option.vpnserver])

    if 'cis' in metafunc.fixturenames:
        metafunc.parametrize("cis", [metafunc.config.option.cis])

    if 'nolinux' in metafunc.fixturenames:
        metafunc.parametrize("nolinux", [metafunc.config.option.nolinux])

    # option_value = metafunc.config.option.snyktoken
    # if 'snyktoken' in metafunc.fixturenames and option_value is not None:
    #     metafunc.parametrize("snyktoken", [option_value])
