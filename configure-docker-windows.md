# Configure Docker Desktop for Insecure Registry

To push images to the registry at `95.217.152.30:5000`, you need to configure Docker Desktop to accept this insecure registry.

## Windows (Docker Desktop)

1. **Open Docker Desktop Settings**
   - Right-click the Docker icon in the system tray
   - Select "Settings"

2. **Navigate to Docker Engine**
   - Click on "Docker Engine" in the left sidebar

3. **Add Insecure Registry**
   - You'll see a JSON configuration. Add the following:
   ```json
   {
     "insecure-registries": ["95.217.152.30:5000"]
   }
   ```
   
   If there are already other settings, add it like this:
   ```json
   {
     "existing-setting": "value",
     "insecure-registries": ["95.217.152.30:5000"]
   }
   ```

4. **Apply & Restart**
   - Click "Apply & restart"
   - Docker will restart with the new configuration

## Alternative: Command Line (if Docker Desktop CLI is available)

```bash
# On Windows (PowerShell as Administrator)
$configPath = "$env:USERPROFILE\.docker\daemon.json"
$config = @{
    "insecure-registries" = @("95.217.152.30:5000")
}
$config | ConvertTo-Json | Set-Content $configPath

# Restart Docker Desktop
Restart-Service docker
```

## Verify Configuration

After restarting, verify the configuration:

```bash
docker info | grep -A 5 "Insecure Registries"
```

You should see `95.217.152.30:5000` in the list.

## Test the Registry

Test connectivity to the registry:

```bash
# Pull a test image
docker pull hello-world

# Tag it for your registry
docker tag hello-world 95.217.152.30:5000/test

# Try to push
docker push 95.217.152.30:5000/test
```

If the push succeeds, you're ready to deploy eaglegpt!