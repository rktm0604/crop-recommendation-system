# Contributing to SmartCrop

Thank you for your interest in contributing! Here's how to get started.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/crop-recommendation-system.git
   ```
3. **Create a branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** and commit:
   ```bash
   git commit -m "feat: add your feature description"
   ```
5. **Push** and open a Pull Request:
   ```bash
   git push origin feature/your-feature-name
   ```

## 📝 Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:**

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `chore` | Build process, CI, dependencies |

**Examples:**
```
feat(recommendation): add confidence threshold filter
fix(auth): resolve JWT token expiration issue
docs(readme): update API reference section
refactor(service): extract weather client to separate class
```

## 🎨 Code Style

- **Java 17** features are welcome
- Follow existing naming conventions
- Use `@Slf4j` (Lombok) for logging
- DTOs for all API request/response objects
- Proper exception handling via `GlobalExceptionHandler`

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run with demo profile (H2)
mvn test -Dspring.profiles.active=demo
```

## 📋 Pull Request Checklist

- [ ] Code compiles without errors
- [ ] Follows existing code style
- [ ] Commit messages follow conventional format
- [ ] README updated if adding new features/endpoints
- [ ] No hardcoded credentials or secrets

## 🐛 Bug Reports

Open an issue with:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior
4. Environment (OS, Java version, MySQL version)

---

Thank you for helping make SmartCrop better! 🌿
