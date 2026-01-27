---
name: azure-identity-sdk
description: Help developers choose and use the right Azure Identity SDK credential class for authentication in their applications
---

# Azure Identity SDK

## Quick Reference

| Property | Value |
|----------|-------|
| Package names | `Azure.Identity` (.NET), `@azure/identity` (JavaScript/TypeScript), `azure-identity` (Python), `azure-identity` (Java) |
| Best for | Azure service authentication, automated credential selection, secure identity management |
| Official Docs | [Azure Identity client library](https://learn.microsoft.com/en-us/dotnet/azure/sdk/authentication/) |

## When to Use This Skill

Use this skill when developers need help with:
- Choosing the right credential class for Azure authentication
- Understanding the difference between credential types
- Implementing authentication in Azure applications
- Migrating from connection strings or keys to credential-based authentication
- Troubleshooting DefaultAzureCredential issues
- Setting up authentication for local development vs. production

## Example User Queries

- "Which Azure credential should I use for my app?"
- "How do I authenticate to Azure services in my code?"
- "What's the difference between ManagedIdentityCredential and EnvironmentCredential?"
- "How does DefaultAzureCredential work?"
- "My DefaultAzureCredential is failing, what should I check?"
- "Best way to authenticate to Azure Key Vault from my app?"
- "How to set up authentication for local development and production?"

## Overview

The Azure Identity SDK provides Azure Active Directory (Azure AD) token authentication across the Azure SDK. It offers several credential classes that encapsulate different authentication methods, making it easy to authenticate to Azure services without managing secrets directly in code.

### Key Principle

**Always prefer credential-based authentication over connection strings or access keys** for better security, auditability, and compliance.

## Credential Classes

### DefaultAzureCredential (Recommended for Most Scenarios)

**What it is:** A chain of credentials that tries multiple authentication methods in a specific order until one succeeds.

**When to use:**
- You want seamless authentication across development, staging, and production environments
- You don't want to change authentication code when moving from local to cloud
- You're not sure which specific credential to use

**How it works:**
DefaultAzureCredential attempts credentials in this order:

1. **EnvironmentCredential** - Checks environment variables
2. **WorkloadIdentityCredential** - For Azure Kubernetes Service workload identity
3. **ManagedIdentityCredential** - For Azure resources with managed identity
4. **SharedTokenCacheCredential** - Uses shared token cache (Azure CLI, Visual Studio)
5. **VisualStudioCredential** - Uses Visual Studio signed-in account
6. **VisualStudioCodeCredential** - Uses VS Code signed-in account (deprecated)
7. **AzureCliCredential** - Uses Azure CLI logged-in account
8. **AzurePowerShellCredential** - Uses Azure PowerShell logged-in account
9. **AzureDeveloperCliCredential** - Uses Azure Developer CLI logged-in account
10. **InteractiveBrowserCredential** - Prompts user login via browser

**Example usage:**

.NET:
```csharp
using Azure.Identity;

var credential = new DefaultAzureCredential();
var client = new SecretClient(new Uri("https://myvault.vault.azure.net/"), credential);
```

JavaScript/TypeScript:
```javascript
const { DefaultAzureCredential } = require("@azure/identity");

const credential = new DefaultAzureCredential();
const client = new SecretClient("https://myvault.vault.azure.net/", credential);
```

Python:
```python
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://myvault.vault.azure.net/", credential=credential)
```

**Pros:**
- Works across all environments without code changes
- Automatic fallback between credential types
- Best for general-purpose use

**Cons:**
- May try multiple credentials before succeeding (slight performance overhead)
- Harder to debug when authentication fails
- Some credentials in the chain may not be needed for your scenario

---

### Individual Credential Classes

Use these when you need specific authentication behavior or want to avoid the DefaultAzureCredential chain.

#### EnvironmentCredential

**What it is:** Authenticates using service principal credentials from environment variables.

**When to use:**
- CI/CD pipelines
- Containerized applications with injected secrets
- Applications that need consistent authentication across different platforms

**Required environment variables:**

For service principal with client secret:
```bash
AZURE_CLIENT_ID=<service-principal-client-id>
AZURE_TENANT_ID=<azure-tenant-id>
AZURE_CLIENT_SECRET=<service-principal-secret>
```

For service principal with certificate:
```bash
AZURE_CLIENT_ID=<service-principal-client-id>
AZURE_TENANT_ID=<azure-tenant-id>
AZURE_CLIENT_CERTIFICATE_PATH=<path-to-certificate>
```

For user with username/password (not recommended):
```bash
AZURE_CLIENT_ID=<application-client-id>
AZURE_TENANT_ID=<azure-tenant-id>
AZURE_USERNAME=<username>
AZURE_PASSWORD=<password>
```

**Example:**
```csharp
var credential = new EnvironmentCredential();
```

**Pros:**
- Explicit and predictable
- Works in any environment that supports environment variables
- Good for CI/CD

**Cons:**
- Requires managing and securing environment variables
- Secrets must be rotated periodically

---

#### WorkloadIdentityCredential

**What it is:** Authenticates using Azure Workload Identity (federated identity for Kubernetes).

**When to use:**
- Azure Kubernetes Service (AKS) workloads
- Applications running in Kubernetes with workload identity enabled
- Replacing pod-managed identity

**Setup:**
Requires AKS cluster configured with workload identity and a service account bound to an Azure AD application.

**Example:**
```csharp
var credential = new WorkloadIdentityCredential();
```

**Pros:**
- No secrets to manage
- Native Kubernetes integration
- Better security than pod-managed identity

**Cons:**
- Only works in Kubernetes with workload identity configured
- Requires initial setup and configuration

---

#### ManagedIdentityCredential

**What it is:** Authenticates using managed identities assigned to Azure resources.

**When to use:**
- Azure VMs
- Azure App Service / Azure Functions
- Azure Container Instances
- Azure Kubernetes Service (AKS)
- Any Azure resource that supports managed identity

**Types:**
- **System-assigned**: Created and tied to the Azure resource lifecycle
- **User-assigned**: Created independently and assigned to one or more resources

**Example:**

System-assigned managed identity:
```csharp
var credential = new ManagedIdentityCredential();
```

User-assigned managed identity:
```csharp
var credential = new ManagedIdentityCredential(clientId: "<user-assigned-identity-client-id>");
```

**Pros:**
- No secrets to manage or rotate
- Automatically managed by Azure
- Best security practice for Azure resources
- No code changes needed when rotating identities

**Cons:**
- Only works on Azure resources with managed identity enabled
- Doesn't work in local development

---

#### VisualStudioCredential

**What it is:** Authenticates using the account signed in to Visual Studio.

**When to use:**
- Local development in Visual Studio
- Seamless development experience without explicit logins

**Example:**
```csharp
var credential = new VisualStudioCredential();
```

**Pros:**
- Convenient for Visual Studio users
- No additional authentication needed

**Cons:**
- Only works in Visual Studio environment
- Not suitable for CI/CD or production
- Windows-only

---

#### VisualStudioCodeCredential (Deprecated)

**Status:** Deprecated - The VS Code Azure Account extension is deprecated.

**Recommendation:** Use `AzureCliCredential` or other developer credentials instead.

---

#### AzureCliCredential

**What it is:** Authenticates using the Azure CLI logged-in account.

**When to use:**
- Local development when using Azure CLI
- CI/CD pipelines with Azure CLI installed
- Developers who prefer CLI-based workflows

**Prerequisites:**
```bash
az login
```

**Example:**
```csharp
var credential = new AzureCliCredential();
```

**Pros:**
- Works across platforms
- Common in developer workflows
- Can be used in CI/CD with Azure CLI

**Cons:**
- Requires Azure CLI to be installed
- Tokens expire and require re-authentication

---

#### AzurePowerShellCredential

**What it is:** Authenticates using the Azure PowerShell logged-in account.

**When to use:**
- Developers using Azure PowerShell
- PowerShell automation scripts
- Windows-centric environments

**Prerequisites:**
```powershell
Connect-AzAccount
```

**Example:**
```csharp
var credential = new AzurePowerShellCredential();
```

**Pros:**
- Integrates with PowerShell workflows
- Useful for automation scripts

**Cons:**
- Requires Azure PowerShell module
- Less common than Azure CLI

---

#### AzureDeveloperCliCredential

**What it is:** Authenticates using the Azure Developer CLI (azd) logged-in account.

**When to use:**
- Developers using Azure Developer CLI
- Modern full-stack Azure application development

**Prerequisites:**
```bash
azd auth login
```

**Example:**
```csharp
var credential = new AzureDeveloperCliCredential();
```

**Pros:**
- Integrates with modern Azure development workflows
- Good for azd-based projects

**Cons:**
- Requires Azure Developer CLI
- Less widely adopted than Azure CLI

---

#### InteractiveBrowserCredential

**What it is:** Prompts the user to authenticate via a web browser.

**When to use:**
- Desktop applications that need user authentication
- Development scenarios without pre-configured credentials
- When other automated credentials are not available

**Example:**
```csharp
var credential = new InteractiveBrowserCredential();
```

**Pros:**
- Works across platforms
- Good user experience for interactive apps
- No pre-configuration needed

**Cons:**
- Requires user interaction
- Not suitable for automated scenarios or headless environments
- May require firewall/network configuration for redirect URLs

---

#### BrokerCredential

**What it is:** Uses Windows Authentication Broker for interactive and silent authentication.

**When to use:**
- Windows applications requiring enterprise-grade authentication
- Applications needing single sign-on (SSO) with Windows
- When Web Account Manager (WAM) integration is desired

**Prerequisites:**
- Requires `Azure.Identity.Broker` package
- Windows operating system
- Appropriate broker configuration

**Example:**
```csharp
var credential = new BrokerCredential();
```

**Pros:**
- Enables SSO on Windows
- Secure token management via OS-level broker
- Better security than browser-based flows

**Cons:**
- Windows-only
- Requires additional package
- More complex setup

---

## Decision Guide: Which Credential to Use?

### For Production (Azure-hosted applications)

| Scenario | Recommended Credential | Why |
|----------|------------------------|-----|
| Azure VM, App Service, Functions | `ManagedIdentityCredential` | No secrets, automatic, most secure |
| Azure Kubernetes Service (AKS) | `WorkloadIdentityCredential` | Native Kubernetes integration, no secrets |
| Container Apps, Container Instances | `ManagedIdentityCredential` | No secrets, automatic |
| CI/CD Pipeline | `EnvironmentCredential` | Controlled via environment variables |
| Multi-environment (dev/test/prod) | `DefaultAzureCredential` | Works everywhere with proper setup |

### For Local Development

| Scenario | Recommended Credential | Why |
|----------|------------------------|-----|
| Using Visual Studio | `VisualStudioCredential` or `DefaultAzureCredential` | Seamless VS integration |
| Using Azure CLI | `AzureCliCredential` or `DefaultAzureCredential` | Leverages existing login |
| Using Azure Developer CLI | `AzureDeveloperCliCredential` or `DefaultAzureCredential` | Integrates with azd workflows |
| Desktop app requiring user login | `InteractiveBrowserCredential` | User-friendly browser flow |
| Don't want to think about it | `DefaultAzureCredential` | Automatic selection |

### For Special Cases

| Scenario | Recommended Credential | Why |
|----------|------------------------|-----|
| Kubernetes with workload identity | `WorkloadIdentityCredential` | Purpose-built for K8s federation |
| Service principal in containers | `EnvironmentCredential` | Clean secret injection |
| Windows enterprise app | `BrokerCredential` | SSO and WAM support |
| PowerShell automation | `AzurePowerShellCredential` | PowerShell integration |

---

## Common Patterns

### Pattern 1: Development + Production with DefaultAzureCredential

**Setup:**
- Local: Use Azure CLI (`az login`)
- Production: Enable managed identity on Azure resource

**Code (same for both):**
```csharp
var credential = new DefaultAzureCredential();
var client = new SecretClient(vaultUri, credential);
```

**How it works:**
- Local: DefaultAzureCredential uses AzureCliCredential
- Production: DefaultAzureCredential uses ManagedIdentityCredential

**Benefits:**
- No code changes between environments
- Secure in both environments

---

### Pattern 2: Explicit Credentials for Clarity

**Local development:**
```csharp
#if DEBUG
var credential = new AzureCliCredential();
#else
var credential = new ManagedIdentityCredential();
#endif
```

**Benefits:**
- Clear which credential is used
- Easier to debug
- Explicit control

---

### Pattern 3: User-Assigned Managed Identity

**When you have multiple user-assigned identities:**

```csharp
var credential = new ManagedIdentityCredential(
    new ManagedIdentityClientId("<user-assigned-identity-client-id>")
);
```

---

### Pattern 4: Chaining Custom Credentials

**Create your own credential chain:**

```csharp
var credential = new ChainedTokenCredential(
    new ManagedIdentityCredential(),
    new AzureCliCredential(),
    new InteractiveBrowserCredential()
);
```

**Benefits:**
- Custom order of attempts
- Include only what you need
- Better performance than DefaultAzureCredential

---

## Troubleshooting DefaultAzureCredential

### Issue: "DefaultAzureCredential failed to retrieve a token"

**Check in order:**

1. **Environment variables** - Are `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_CLIENT_SECRET` set?
2. **Managed identity** - Is it enabled on the Azure resource?
3. **Azure CLI** - Run `az account show` to verify login
4. **Visual Studio** - Check Tools → Options → Azure Service Authentication
5. **Network/firewall** - Can you reach Azure AD endpoints?

**Enable logging to see which credentials are tried:**

.NET:
```csharp
using Azure.Core.Diagnostics;

using var listener = AzureEventSourceListener.CreateConsoleLogger();
var credential = new DefaultAzureCredential();
```

### Issue: Slow authentication in production

**Solution:** Use specific credential instead of DefaultAzureCredential:
```csharp
var credential = new ManagedIdentityCredential();
```

This avoids trying multiple credentials in the chain.

### Issue: Works locally but fails in Azure

**Common causes:**
- Managed identity not enabled on the Azure resource
- Managed identity not granted permissions to the resource (e.g., Key Vault)
- Using user-assigned identity but not specifying client ID

**Solution:**
1. Enable managed identity in Azure Portal
2. Grant proper RBAC roles (e.g., "Key Vault Secrets User")
3. For user-assigned, specify client ID explicitly

---

## Best Practices

### Security

1. **Prefer managed identities** over service principals for Azure resources
2. **Never hardcode credentials** in source code
3. **Use environment variables** for service principals in CI/CD
4. **Rotate secrets regularly** if using EnvironmentCredential
5. **Grant least-privilege access** to managed identities
6. **Enable logging** to audit authentication attempts

### Development

1. **Use DefaultAzureCredential** for seamless dev-to-prod workflows
2. **Use Azure CLI** (`az login`) for local development convenience
3. **Test with explicit credentials** when debugging authentication issues
4. **Document which credential** your app expects in production
5. **Use conditional compilation** (#if DEBUG) if you need different credentials per environment

### Performance

1. **Use specific credentials** in performance-critical paths to avoid the chain overhead
2. **Cache credential instances** - they're designed to be reused
3. **Don't create new credentials** on every request

### Monitoring

1. **Log authentication attempts** in production
2. **Monitor token refresh failures**
3. **Set up alerts** for authentication failures
4. **Track credential usage** to understand which credentials are being used

---

## Migration Scenarios

### From Connection Strings to Credentials

**Before:**
```csharp
var connectionString = "DefaultEndpointsProtocol=https;AccountName=...;AccountKey=...";
var client = new BlobServiceClient(connectionString);
```

**After:**
```csharp
var credential = new DefaultAzureCredential();
var client = new BlobServiceClient(
    new Uri("https://myaccount.blob.core.windows.net"),
    credential
);
```

**Don't forget:**
- Enable managed identity on your Azure resource
- Grant "Storage Blob Data Contributor" role to the managed identity

### From Access Keys to Credentials

**Before:**
```csharp
var client = new SecretClient(
    vaultUri,
    new ClientSecretCredential(tenantId, clientId, clientSecret)
);
```

**After:**
```csharp
var credential = new DefaultAzureCredential();
var client = new SecretClient(vaultUri, credential);
```

---

## FAQ

**Q: Should I always use DefaultAzureCredential?**
A: For most applications, yes. It provides the best balance of flexibility and convenience. Use specific credentials only when you need explicit control or better performance.

**Q: How do I know which credential DefaultAzureCredential is using?**
A: Enable diagnostic logging to see the credential chain attempts.

**Q: Can I use managed identity for local development?**
A: No, managed identity only works on Azure resources. Use Azure CLI or Visual Studio credentials locally.

**Q: What's the difference between system-assigned and user-assigned managed identity?**
A: System-assigned is tied to the resource lifecycle (deleted when resource is deleted). User-assigned is independent and can be assigned to multiple resources.

**Q: Do I need to rotate credentials when using managed identity?**
A: No, Azure handles token management and rotation automatically.

**Q: Can I use the same code for .NET, Python, JavaScript, and Java?**
A: Yes, the Azure Identity libraries follow the same patterns across languages, though syntax differs.

**Q: What permissions does a managed identity need?**
A: Depends on the Azure service. For example:
- Key Vault: "Key Vault Secrets User" or "Key Vault Secrets Officer"
- Storage: "Storage Blob Data Contributor" or "Storage Blob Data Reader"
- SQL: Assign database user and roles

---

## Additional Resources

- [Azure Identity client library for .NET](https://learn.microsoft.com/en-us/dotnet/api/azure.identity)
- [Azure Identity client library for JavaScript](https://www.npmjs.com/package/@azure/identity)
- [Azure Identity client library for Python](https://learn.microsoft.com/en-us/python/api/azure-identity)
- [Azure Identity client library for Java](https://learn.microsoft.com/en-us/java/api/overview/azure/identity-readme)
- [Credential chains in Azure Identity](https://learn.microsoft.com/en-us/dotnet/azure/sdk/authentication/credential-chains)
- [Managed identities for Azure resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
