# Stripe MCP

**When:** Using Stripe for payments (you use it a lot!)

**Setup:**

1. Install Stripe MCP from registry
2. Add to Claude Code settings
3. Set environment variables:
   ```bash
   STRIPE_SECRET_KEY=sk_test_...
   STRIPE_WEBHOOK_SECRET=whsec_...  # Optional but recommended
   ```

**Source:** [Stripe MCP docs](https://docs.stripe.com/mcp)

---

## Use Cases

**During development:**
```bash
# Inside Claude Code
"Create a Stripe checkout session for product X"
"Test the webhook handler for payment_intent.succeeded"
"List all customers with active subscriptions"
```

**Claude can:**
- Create products and prices
- Generate checkout sessions
- Handle webhook events
- Query customer data
- Test payment flows

---

## CLAUDE.md Integration

Add to your project's CLAUDE.md:

```markdown
## Stripe / Payments

### Security Rules
- NEVER log full card details
- ALWAYS validate webhook signatures
- Use Stripe test mode in development
- Store minimal PII (use Stripe Customer ID, not full details)

### Test Mode
- Test cards: 4242 4242 4242 4242 (success), 4000 0000 0000 0002 (decline)
- Webhook testing: Use Stripe CLI or Stripe Dashboard webhooks

### Error Handling
- Card declined: Show user-friendly message
- Webhook failures: Log and retry with exponential backoff
- Idempotency: Use idempotency keys for create operations
```

---

## Common Patterns

**Checkout flow:**
```typescript
// Create checkout session
const session = await stripe.checkout.sessions.create({
  mode: 'subscription',
  line_items: [{ price: 'price_...', quantity: 1 }],
  success_url: 'https://yourapp.com/success',
  cancel_url: 'https://yourapp.com/cancel',
})
```

**Webhook handler:**
```typescript
// Verify signature
const sig = request.headers['stripe-signature']
const event = stripe.webhooks.constructEvent(body, sig, webhookSecret)

// Handle event
switch (event.type) {
  case 'payment_intent.succeeded':
    // Fulfill order
    break
  case 'customer.subscription.deleted':
    // Cancel access
    break
}
```

---

## Resources

- [Stripe docs](https://stripe.com/docs)
- [Stripe MCP](https://docs.stripe.com/mcp)
- [Stripe testing](https://stripe.com/docs/testing)
