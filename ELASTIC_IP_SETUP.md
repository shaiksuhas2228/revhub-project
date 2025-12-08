# AWS Elastic IP Setup Guide

## Why Use Elastic IP?
An Elastic IP ensures your EC2 instance keeps the same public IP address even after stopping and starting, eliminating the need to update configuration files every time.

---

## Steps to Allocate and Associate Elastic IP

### 1. Allocate Elastic IP

1. Go to **AWS Console** → **EC2 Dashboard**
2. In the left sidebar, click **Elastic IPs** (under Network & Security)
3. Click **Allocate Elastic IP address**
4. Select **Amazon's pool of IPv4 addresses**
5. Click **Allocate**
6. Note down the allocated IP address

### 2. Associate Elastic IP with Your EC2 Instance

1. Select the newly allocated Elastic IP
2. Click **Actions** → **Associate Elastic IP address**
3. Select:
   - **Resource type**: Instance
   - **Instance**: Choose your RevHub EC2 instance
   - **Private IP address**: Select the private IP (auto-populated)
4. Click **Associate**

### 3. Update Security Group (if needed)

Ensure your security group allows traffic on required ports:
- Port 22 (SSH)
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 4200 (Frontend)
- Port 8080 (Backend)

### 4. Update Your Configuration Files

Once you have the Elastic IP, update these files with the new IP:

**Angular Services:**
- `src/app/core/services/auth.service.ts`
- `src/app/core/services/chat.service.ts`
- `src/app/core/services/notification.service.ts`
- `src/app/core/services/post.service.ts`
- `src/app/core/services/profile.service.ts`

**Documentation:**
- `EC2_COMMANDS.md`
- `DEPLOY_TO_EC2.md`

### 5. Connect Using Elastic IP

```powershell
ssh -i revhub-key.pem ubuntu@YOUR_ELASTIC_IP
```

---

## Important Notes

⚠️ **Elastic IP Charges:**
- Elastic IPs are **FREE** when associated with a running instance
- You are **charged** if the Elastic IP is allocated but NOT associated with a running instance
- You are **charged** if the instance is stopped but the Elastic IP remains associated

💡 **Best Practice:**
- Always associate Elastic IP with your instance
- If you stop your instance for extended periods, consider releasing the Elastic IP to avoid charges

---

## Release Elastic IP (When No Longer Needed)

1. **Disassociate** the Elastic IP from the instance first
2. Then **Release** the Elastic IP address

---

## Current Configuration

**Current IP:** 3.151.228.198 (Elastic IP - PERMANENT)
**Status:** ✅ Elastic IP configured - IP will never change!

---

## Quick Command Reference

```bash
# Check current public IP on EC2
curl ifconfig.me

# After associating Elastic IP, verify
curl ifconfig.me
```

The IP should match your allocated Elastic IP address.
