# Service Dependency Graph

```mermaid
graph TD
    Telegram[Telegram API] -->|Webhooks / Polling| Control(Werewolf Control Node)

    Control -->|gRPC / RPC| Worker1(Werewolf Node 1)
    Control -->|gRPC / RPC| Worker2(Werewolf Node N)

    Worker1 -->|Read/Write| MongoDB[(MongoDB Atlas)]
    Worker2 -->|Read/Write| MongoDB

    Control -->|Log| Logger
    Worker1 -->|Log| Logger

    OpenAI[OpenAI API] <--> Worker1

    Stripe[Stripe API] --> Donation(Donation Service)
    Xsolla[Xsolla API] --> Donation

    Donation -->|Write| MongoDB

    AdminWeb(Website/Admin Panel) -->|Read/Write| MongoDB
    AdminWeb <-->|Admin Commands| Control
```

## Key Dependencies
1. **Telegram API:** Entry point for all user interaction.
2. **MongoDB Atlas:** Central state storage for stats, bans, and user profiles. Game state during active play is kept in Node memory.
3. **OpenAI:** Used within the game loop (Node) for dummy defense text.
4. **Payment Providers:** Triggers webhooks in the Donation service.
