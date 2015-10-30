# TODO

- [ ] storage doesn't seem to ever get stored!

- [ ] cleanup init params to allow multiple adapters
- [ ] write Nerves.Test.MockCLI
- [ ] put api in for setting params, getting state, etc
- [ ] write tests for api based on MockCLI
- [x] separate out udhcpc dependencies into module

- [ ] link state should be able to be brought up or down through api
make sure status:static gets stored if we care.

- the entire storage stuff should be factored out of ethernet. It has no place there.  Ultimately it's about when it gets setup, it gets initialized, and those are parameters to setup, not anything else.
