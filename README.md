## On-Chain HTML Registry

On-chain HTML registry singleton for protocols and accounts. Store and retrieve
versioned HTML content directly from the blockchain.

- No DNS.
- No provider.
- **Fallback UI** for protocols and accounts.

Spin up a local DApp in one line:

```bash
cast call 0xFa11bacCdc38022dbf8795cC94333304C9f22722 'html(address)(string)' PROTOCOL_ADDRESS \
  -r RPC_URL | jq -r . >index.html && python3 -m http.server 8000
```

Thanks to [`@z0r0zzz`](https://x.com/z0r0zzz) for the
[idea](https://x.com/z0r0zzz/status/2045794052504015079).

## How it works

Content is stored via
[SSTORE2](https://github.com/Vectorized/solady/blob/main/src/utils/SSTORE2.sol)
(allowing for a max of ~24KB per write). Each write is immutable and creates a
new incremental version. The mapping is structured as
`author => target => version => content`.

The canonical read is `html(target)`, which is shorthand for
`html(target,target)`: the target publishing HTML about itself. You can also
read cross-authored content via `html(author,target)`.

**Authorization**: writing to `target => target` is permitted if:

- `msg.sender == target`, or
- `msg.sender == target.owner()`

```solidity
// Write as msg.sender
setHtml(address target, string calldata htmlData)

// Write as the target
setHtmlAsTarget(address target, string calldata htmlData)

// Read latest, canonical shorthand, author == target
html(address addr)

// Read latest, explicit author and target
html(address author, address target)

// Read specific version
html(address author, address target, uint256 version)
```

This means an address can register its own UI, or the `owner()` of the contract
can do it on its behalf (`html(target)`). If the contract is not ownable (or
uses another interface, such as role-based ownership) and has no way to call the
registry, then it's recommended to use a trusted author and target and mention
that in the protocol's documentation, calling `html(author,target)`.

Listen for `HTMLRegistry__HtmlSet` events to track updates. If in doubt that the
frontend might be compromised, one can call `latestVersion(author,target)` at a
past block to get the trusted past version and use it in
`html(author,target,version)`.

## Security

This contract has not been formally audited. It has been reviewed and tested,
but no guarantees are made. **Use at your own risk.**

## Deployments

The registry is deployed as a singleton (via
[createx](https://github.com/pcaversaccio/createx)) at the address
[`0xFa11bacCdc38022dbf8795cC94333304C9f22722`](https://sourcify.dev/#/lookup/0xFa11bacCdc38022dbf8795cC94333304C9f22722).

Currently deployed to:

- [Mainnet](https://etherscan.io/address/0xfa11baccdc38022dbf8795cc94333304c9f22722)

If you need it to be deployed to another chain, you can do it yourself as the
deployment is permissionless. You can do it via the `HTMLRegistryDeploy` script,
like so:

```bash
forge script script/HTMLRegistryDeploy.s.sol --rpc-url 'RPC_URL_OF_MISSING_CHAIN' --broadcast
```

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
