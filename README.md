## On-Chain HTML Registry

On-chain HTML registry for protocols and accounts. Store and retrieve versioned
HTML content directly from the blockchain.

- No DNS.
- No provider.
- Fallback UI for protocols and accounts.

Spin up a local DApp in one line:

```bash
cast call HTML_REGISTRY_ADDRESS 'html(address)(bytes)' PROTOCOL_ADDRESS \
  -r RPC_URL | xxd -r -p >index.html && python3 -m http.server 8000
```

## How it works

Content is stored via
[SSTORE2](https://github.com/Vectorized/solady/blob/main/src/utils/SSTORE2.sol).
Each write is immutable and creates a new incremental version. The mapping is
structured as `author => target => version => content`.

The canonical read is `html(target)`, which is shorthand for
`html(target, target)`: the target publishing HTML about itself. You can also
read cross-authored content via `html(author, target)`.

**Authorization**: writing to `author => target` is permitted if:

- `msg.sender == target`, or
- `msg.sender == target.owner()`

This means a protocol can register its own UI, or a multisig/deployer that owns
the protocol contract can do it on its behalf.

Listen to `HTMLRegistry__HtmlSet` events to track updates.

```solidity
// Write as msg.sender about a target
setHtml(address target, bytes calldata htmlData)

// Write as the target
setHtmlAsTarget(address target, bytes calldata htmlData)

// Read latest, canonical shorthand, author == target
html(address addr)

// Read latest, explicit author and target
html(address author, address target)

// Read specific version
html(address author, address target, uint256 version)
```

Thanks to [`@z0r0zzz`](https://x.com/z0r0zzz) for the
[idea](https://x.com/z0r0zzz/status/2045794052504015079).

## Development

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Coverage

```shell
$ forge coverage
```

### Gas Snapshots

```shell
$ forge snapshot
```
