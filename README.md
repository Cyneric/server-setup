# Linux System Setup Scripts

A comprehensive automation toolkit for standardizing Linux server configurations. This collection of scripts streamlines the process of setting up new servers by automating common configuration tasks and implementing best practices for server management.

## Why Use This?

### Standardization
- Ensures consistent configuration across all your servers
- Reduces human error in setup process
- Maintains uniform security practices

### Security Features
- Automated SSH key management
- Secure file permissions handling
- Centralized logging setup
- Login/Logout tracking with notifications

### Time-Saving
- Reduces server setup time from hours to minutes
- Automates repetitive configuration tasks
- Handles distribution-specific package management

### Monitoring & Logging
- Instant notifications for server access via Gotify
- Centralized syslog configuration
- Login/Logout tracking for security auditing
- System resource monitoring

### Multi-Distribution Support
- Works across major Linux distributions
- Handles package manager differences automatically
- Adapts configurations to distribution specifics

### Easy Maintenance
- Version tracking for configurations
- Simple update mechanism
- Backup of critical files before modifications
- Idempotent operations (safe to run multiple times)

## Features

- Multi-distribution support (Debian, Ubuntu, Arch, Alpine)
- Automated system configuration
- SSH key management
- Syslog configuration
- Login/Logout tracking via Gotify notifications
- Oh My Posh shell customization
- Custom MOTD (Message of the Day)
- Optional system utilities:
  - htop (system monitoring)
  - nano (text editor)
  - neofetch/screenfetch (system information display)

## Prerequisites

- Root access
- One of the supported Linux distributions
- Internet connection
- Gotify server (for login/logout notifications)

## Quick Install

### Option 1: Interactive Installation

Simply run:
```bash
curl -sSL https://raw.githubusercontent.com/Cyneric/shellscripts/main/bootstrap.sh | sudo bash
```

### Option 2: Installation with Configuration File

1. Create your config.json file:
```bash
curl -O https://raw.githubusercontent.com/Cyneric/shellscripts/main/config.example.json
mv config.example.json config.json
```

2. Edit the configuration:
```bash
nano config.json
```

Example configuration:
```json
{
    "ssh": {
        "public_key": "YOUR_SSH_PUBLIC_KEY"
    },
    "syslog": {
        "server": "YOUR_SYSLOG_SERVER_IP",
        "port": "YOUR_SYSLOG_PORT"
    },
    "gotify": {
        "url": "http://your-gotify-server/message",
        "token": "YOUR_GOTIFY_APP_TOKEN"
    }
}
```

3. Run the installation with your config file:
```bash
curl -sSL https://raw.githubusercontent.com/Cyneric/shellscripts/main/bootstrap.sh | sudo bash -s -- config.json
```

### Option 3: Installation with GitHub Credentials

This method allows you to securely store your credentials in GitHub Secrets and retrieve them during installation.

1. Set up GitHub Secrets:
   - Go to your GitHub repository
   - Navigate to Settings → Secrets and Variables → Actions
   - Add the following secrets:
     ```
     SSH_PUBLIC_KEY: Your SSH public key
     SYSLOG_IP: Your syslog server IP
     SYSLOG_PORT: Your syslog server port
     GOTIFY_URL: Your Gotify server URL
     GOTIFY_TOKEN: Your Gotify application token
     ```

2. Create a GitHub Personal Access Token (PAT):
   - Go to GitHub Settings → Developer Settings → Personal Access Tokens
   - Create a new token with `repo` scope
   - Save the token securely

3. Run the installation:
```bash
curl -sSL https://raw.githubusercontent.com/Cyneric/shellscripts/main/bootstrap.sh | sudo bash
```

4. When prompted:
   - Choose "Yes" to fetch credentials from GitHub
   - Enter your Personal Access Token
   - The script will automatically fetch and configure your credentials

This method is recommended for:
- Managing multiple servers
- Keeping credentials secure and centralized
- Easy credential updates across all systems

## Configuration Components

### Credentials Management
You have several options to configure your credentials:

1. **Manual Configuration**
   - Enter values when prompted during installation
   - Best for single-server setups

2. **Configuration File**
   - Create and edit config.json manually
   - Useful for repeatable deployments
   ```bash
   curl -O https://raw.githubusercontent.com/Cyneric/shellscripts/main/config.example.json
   mv config.example.json config.json
   nano config.json
   ```

3. **GitHub Secrets (Recommended)**
   - Store credentials securely in GitHub
   - Easy to manage across multiple servers
   
   Setup steps:
   1. Store your credentials as GitHub Secrets:
      - Go to your GitHub repository
      - Navigate to Settings → Secrets and Variables → Actions
      - Add the following secrets:
        - `SSH_PUBLIC_KEY`: Your SSH public key
        - `SYSLOG_IP`: Your syslog server IP
        - `SYSLOG_PORT`: Your syslog server port
        - `GOTIFY_URL`: Your Gotify server URL
        - `GOTIFY_TOKEN`: Your Gotify application token

   2. Create a Personal Access Token (PAT):
      - Go to GitHub Settings → Developer Settings → Personal Access Tokens
      - Create a new token with `repo` scope
      - Save the token securely

   3. During installation:
      - Choose "Yes" when prompted to fetch from GitHub
      - Enter your Personal Access Token
      - Credentials will be automatically configured

   Security Notes:
   - Keep your PAT secure and never share it
   - Use tokens with minimal necessary permissions
   - Enable 2FA on your GitHub account
   - Regularly rotate your PAT

### Gotify Setup
The script uses Gotify for login/logout notifications. To set up:
1. Install a Gotify server or use an existing one
2. Create a new application in Gotify
3. Copy the application token
4. Add the Gotify server URL (with /message endpoint) and token to config.json

### SSH Keys
Manages SSH key-based authentication for secure access.

### Syslog
Configures remote syslog forwarding to your central log server.

### Optional Packages
During installation, you'll be prompted to install additional useful packages:

- **System Monitor (htop)**
  - Interactive process viewer
  - Real-time system statistics
  - Detailed resource usage

- **Text Editor (nano)**
  - User-friendly command-line editor
  - Syntax highlighting
  - Easy-to-use interface

- **System Information Display**
  - Choice between neofetch or screenfetch
  - Shows system specifications
  - Displays distribution logo

### Optional Features
During installation, you'll be prompted to enable various optional features:

- **Remote Logging**
  - Forwards system logs to a central syslog server
  - Requires syslog server details
  - Useful for centralized log management

- **Login Notifications**
  - Sends notifications via Gotify when users log in/out
  - Requires Gotify server and token
  - Great for security monitoring

These features can be enabled/disabled during installation or reconfiguration.

## Post-Installation

After installation:
1. Log out and back in to activate all features
2. Check the MOTD for installation confirmation
3. Verify Gotify notifications are working
4. Test SSH key access if configured

## Updating

To update an existing installation, simply run the bootstrap script again:
```bash
curl -sSL https://raw.githubusercontent.com/Cyneric/shellscripts/main/bootstrap.sh | sudo bash
```

The script will:
1. Detect the existing installation
2. Check the current version
3. Prompt for updates if needed
4. Maintain existing configuration


## Supported Distributions

- Ubuntu
- Debian
- Arch Linux
- Alpine Linux

## Project Structure
```code
.
├── LICENSE
├── README.md
├── bootstrap.sh
├── config/
│   ├── settings.template.sh
│   └── setup_config.sh
├── config.example.json
├── lib/
│   └── utils.sh
└── modules/
    ├── login.sh
    ├── logout.sh
    └── ssh_setup.sh
```

## Configuration Details

### SSH Key Format
The SSH public key should be in OpenSSH format. Example:
```text
ssh-rsa AAAAB3NzaC1... user@host
```

### Syslog Configuration
Default ports:
- UDP: 514
- TCP: 514
- TLS: 6514

### Gotify URL Format
The URL should include the /message endpoint:
```text
http://your-gotify-server/message
```

## Troubleshooting

### Common Issues
1. SSH key not working
   - Check key format
   - Verify permissions (600 for authorized_keys)
   - Ensure .ssh directory permissions (700)

2. Gotify notifications not received
   - Verify server URL format
   - Check token permissions
   - Test server connectivity

3. Syslog forwarding issues
   - Check firewall rules
   - Verify port accessibility
   - Test with logger command

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Christian Blank (christianblank91@gmail.com)

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Support

For issues and feature requests, please create an issue in the GitHub repository.
