# Domains

Sentrix protocol services run under `sentrixchain.com`. Product and application services run under `sentriscloud.com`. DNS is managed via Cloudflare.

## Services

| Domain | What |
|--------|------|
| sentrixchain.com | Landing page |
| scan.sentrixchain.com | Block explorer |
| api.sentrixchain.com | REST API |
| rpc.sentrixchain.com | Mainnet JSON-RPC |
| testnet-rpc.sentrixchain.com | Testnet JSON-RPC |
| solux.sentriscloud.com | Solux wallet |
| coinblast.sentriscloud.com | CoinBlast |
| faucet.sentrixchain.com | Testnet faucet |

## Mainnet Endpoints

```
RPC:      https://rpc.sentrixchain.com
API:      https://api.sentrixchain.com
Explorer: https://scan.sentrixchain.com
Wallet:   https://solux.sentriscloud.com
Faucet:   https://faucet.sentrixchain.com
Chain ID: 7119
```

## Testnet Endpoints

```
RPC:      https://testnet-rpc.sentrixchain.com
Chain ID: 7120
```

## For Developers

Connect to testnet (for development and testing):
```
RPC URL:  https://testnet-rpc.sentrixchain.com
Chain ID: 7120
Symbol:   SRX
```

Testnet tokens have no real value. Use the faucet to get test SRX.

```bash
curl https://testnet-rpc.sentrixchain.com/chain/info
curl -X POST https://testnet-rpc.sentrixchain.com/rpc \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

## For Production

Connect to mainnet:
```
RPC URL:  https://rpc.sentrixchain.com
Chain ID: 7119
Symbol:   SRX
```

## Community

- GitHub: https://github.com/sentrix-labs/sentrix
- Telegram (announcements): https://t.me/SentrixChain
