# sam_protocol [![nim-version-img]][nim-version]

[nim-version]: https://nim-lang.org/blog/2019/09/23/version-100-released.html
[nim-version-img]: https://img.shields.io/badge/Nim_-v1.0%2B-blue

**I2P SAM Protocol without any IO.**

```bash
nimble install samprotocol
```

[Documentation](https://gabbhack.github.io/sam_protocol/)

[Examples](https://github.com/gabbhack/sam_protocol/tree/master/examples)

---
This very simple library provides you builders and parsers of [SAM V3](https://geti2p.net/en/docs/api/samv3) messages.

The library itself does not perform any queries, which allows it to be used with any network libraries.


## License
Licensed under <a href="LICENSE">MIT license</a>.

## Acknowledgements
- [nim-stew](https://github.com/status-im/nim-stew), for byteutils
- [i2pd](https://github.com/PurpleI2P/i2pd), for I2P client
