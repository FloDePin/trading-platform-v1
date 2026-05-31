# Trading Platform v1

An open-source, self-hosted multi-bot trading platform for Bitget Futures & Spot, with a real-time web dashboard. Built in pure Python – no cloud, no subscription, no middleman.

![License](https://img.shields.io/badge/license-MIT-green) ![Python](https://img.shields.io/badge/python-3.9%2B-blue) ![Demo Mode](https://img.shields.io/badge/default-demo%20mode-orange)

---

## What it does

Runs up to 4 automated trading bots simultaneously, each on its own Bitget sub-account, controlled through a local browser dashboard. Supports both demo (paper trading) and live mode.

**Signal Bot** – Technical analysis across multiple tokens. Scores 9 indicators and enters long/short positions when the threshold is reached.

**Grid Bot** – Places a grid of buy/sell orders across a price range. Profits from sideways markets.

**Funding Bot** – Tracks funding rate opportunities across tokens for delta-neutral strategies.

**DCA Bot** – Dollar-cost averaging on the Bitget spot market. Buys a fixed amount at regular intervals.

---

## Features

### Bots
- Signal Bot: Wilder RSI, EMA cross (8/20), MACD, Bollinger Bands, Volume Ratio, Funding Rate, Fear & Greed, CoinGecko News Sentiment, Macro Blackout
- ATR-based dynamic Stop Loss and Take Profit
- Position sizing as % of balance
- Correlation check: max N simultaneous positions
- Win/Loss streak tracking
- Multi-Grid: multiple independent grid instances

### Dashboard
- Real-time overview with Fear & Greed history chart (30 days)
- Per-bot PnL sparklines and status
- Open positions across all sub-accounts
- Market tab: live prices for 15+ coins
- Yields tab: DeFi opportunities from DefiLlama
- Economic Calendar with Finnhub
- Trade History with win rate summary
- Backtesting: up to 730 days, walk-forward, Sharpe ratio, fee-adjusted
- Multi-symbol backtest comparison
- Trade Timing Analysis heatmap
- Alerts via Telegram and/or Discord
- Bilingual: Deutsch / English

---

## Installation

### Requirements
- Python 3.9+
- Windows, Linux, or macOS

### Windows
```bash
pip install requests
python platform.py
```
Open `http://localhost:5000`

### Linux / VPS
```bash
bash setup.sh
sudo systemctl start trading-platform
```
Dashboard at `http://your-server-ip:5000`

---

## Configuration

1. Go to **Settings** in the dashboard
2. Create sub-accounts on Bitget (one per bot recommended)
3. Generate API keys: **Read + Trade** only – never Withdraw
4. Enter keys, click **Test Connection**, then **Save**
5. Start in **Demo mode** (default)

### Integrations

| Service | Purpose | Free | Key needed |
|---|---|---|---|
| Finnhub | Economic Calendar | Yes | Yes |
| Telegram | Alerts + Daily Summary | Yes | Bot Token |
| Discord | Alerts + Daily Summary | Yes | Webhook URL |
| CoinGecko | News Sentiment | Yes | No |
| Alternative.me | Fear & Greed | Yes | No |
| DefiLlama | Yield Opportunities | Yes | No |

---

## Security

### Critical rules
- **Never use your main Bitget account.** Use sub-accounts with limited balance.
- **API keys: Read + Trade only.** Never enable Withdraw.
- **Do not expose port 5000 publicly** without restricting access.
- **`platform_config.json` contains API keys.** It is gitignored – never commit it.

### Restrict dashboard access
```bash
# Allow only your IP
ufw allow from YOUR.IP.HERE to any port 5000
ufw deny 5000
```

Or use [Tailscale](https://tailscale.com) for zero-config private VPN access.

### What this platform does NOT do
- Never transmits keys to external services
- Never makes trades outside configured bot logic
- All API calls go to `api.bitget.com` only

---

## Disclaimer

**For educational and experimental purposes only.**

Cryptocurrency trading involves significant financial risk. You can lose all allocated capital. The authors take no responsibility for financial losses. Always start with Demo mode.

---

## Architecture

```
platform.py             Single-file application (~5000 lines)
platform_config.json    API keys and settings (gitignored)
platform.db             SQLite: trade history + PnL snapshots
platform.log            Rotating log (5 MB)
```

---

## License

MIT – free to use, modify, and distribute.

Copyright (c) 2026 Trading Platform Contributors

---

## Critical Setup: One-Way Mode for Grid Bot

Before running the Grid Bot, you **must** switch your Bitget sub-account from Hedge Mode to **One-Way Mode**.

**Why:** Bitget Futures defaults to Hedge Mode (simultaneous long and short allowed). In Hedge Mode, the Grid Bot's sell orders open new short positions instead of closing existing longs. This causes uncontrolled leveraged positions in both directions.

**How to switch:**
1. Open Bitget App or website
2. Go to Futures trading on the Grid Bot sub-account
3. Top right corner → Settings → Position Mode → **One-Way Mode**

This is a one-time setup per sub-account. Signal Bot is not affected (it manages positions explicitly via `tradeSide`).

---

## Exchange Support

Currently, the platform is built exclusively for **Bitget** (Futures + Spot). The `BitgetClient` class handles authentication, order placement, and market data directly via Bitget's REST API.

### Adding More Exchanges (Roadmap)

The platform is designed so that the `BitgetClient` class can be replaced with a universal exchange wrapper using [CCXT](https://github.com/ccxt/ccxt) – a Python library that supports 100+ exchanges with a unified API interface.

Planned exchanges for future support:

| Exchange | Futures | Spot DCA | Demo / Testnet |
|---|---|---|---|
| **Bitget** | Yes (current) | Yes | Yes (`paptrading` header) |
| **Bybit** | Yes | Yes | Yes (Testnet URL) |
| **OKX** | Yes | Yes | Yes (Simulated Trading) |
| **Binance** | Yes | Yes | Yes (Testnet URL) |
| **Gate.io** | Yes | Yes | No |

### What would change with multi-exchange support

- A new `ExchangeClient` base class replacing `BitgetClient`
- Exchange selector dropdown in Settings
- Per-exchange demo mode handling (each exchange implements it differently)
- Everything else – all bots, dashboard, backtest, alerts – stays identical

### Contributing exchange support

If you want to add support for a specific exchange, the key functions to implement are:

```python
client.balance()          # Futures account balance
client.spot_balance(coin) # Spot account balance
client.price(symbol)      # Current market price
client.position(symbol)   # Open position for a symbol
client.funding_rate(symbol) # Current funding rate
client.klines(symbol, limit) # OHLCV candle data
client.place_order(...)   # Place a market order
client.set_leverage(...)  # Set leverage for a symbol
```

Once these are implemented for a new exchange, all four bots will work without any further changes.
