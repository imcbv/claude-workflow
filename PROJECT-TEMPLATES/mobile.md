# Mobile App Template

> **Stack:** React Native / Capacitor
> **Use Case:** iOS and Android apps

---

## CLAUDE.md Quick Config

```markdown
# Project: [APP_NAME]
# Stack: [React Native | Capacitor] + [Backend API]
# Type: [Production | MVP]

## Mobile Standards
- **Navigation:** React Navigation (stack + tab)
- **State:** React Query for server state
- **Storage:** AsyncStorage for simple data, SQLite for complex
- **Forms:** React Hook Form + Zod
- **Styling:** [StyleSheet | Tailwind (NativeWind)]

## Platform-Specific
- **iOS:** Handle safe areas, test on actual device
- **Android:** Handle back button, test permissions

## Performance
- **Images:** Optimize before bundling (< 200KB each)
- **Lists:** Use FlatList with pagination
- **Animations:** Use Reanimated (not Animated API)

## Testing
- **Unit:** Jest + React Native Testing Library
- **E2E:** [Detox | Maestro] for critical flows

## Deployment
- **iOS:** TestFlight → App Store
- **Android:** Internal Testing → Production
```

---

## MCPs Needed

- Context7, GitHub
- Backend API MCPs (if connecting to your backend)

---

## Testing

```bash
# React Native (built-in)
npm test

# E2E with Detox
npx detox test
```
