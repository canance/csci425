# CSCI 425 - Virtual Environment Setup

### Create a Github and DigitalOcean Account
-----------------------
1. Create a [github](http://github.com) account
2. Sign up for a GitHub Education [Student Developer Pack](https://education.github.com/pack)
3. Retrieve your $50 DigitalOcean credit
4. Create a [DigtalOcean](https://www.digitalocean.com/) Account
5. Redeem your Promo code

### Install Vagrant and DigitalOcean Provider
-----------------------
1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
2. Install necessary software for your OS 
- Windows - Install [babun](https://babun.github.io/) *** this will be your terminal ***
- Linux / Mac - Install [git](https://git-scm.com/downloads)
2. In the terminal  run the following command:
    ```bash
    vagrant plugin install vagrant-digitalocean
    ```

### Configure Environment for DigitalOcean Provider
-----------------------
1. [Generate an API Key](https://cloud.digitalocean.com/settings/api/tokens) for your DigitalOcean account 
**Remember to store your API key in a safe place**
2. Determine what shell you are using by running the following command:
    ```bash
    echo $SHELL
    ```
3. Add your API key from step one to your .bashrc or .zshrc file.
	- If your shell is bash:
        ```bash
        echo "export DIGITAL_OCEAN_TOKEN='$API_KEY_FROM_STEP_1'" >> ~/.bashrc
        ```
	- If your shell is zsh:
        ```bash
        echo "export DIGITAL_OCEAN_TOKEN='$API_KEY_FROM_STEP_1'" >> ~/.zshrc
        ```
4. Lastly, if you are using OSX and bash is your shell, you will either want to append the above environment variable to your ~/.bash_profile file or source your .bashrc file from .bash_profile.  Please see here for more information.  To source your .bashrc file from .bash_profile, run the following command:
    ```bash
    echo "if [ -f ~/.bashrc ]; then . ~/.bashrc; fi" >> ~/.bash_profile
    ```

### Configure SSH for Vagrant and DigitalOcean
-----------------------
1. Determine if you need to create an SSH key pair by running the following command:
	```bash
    cat ~/.ssh/id_rsa.pub
    ```
2. If you get an error regarding no such file or directory then create an ssh key pair by running the following command.  
	```bash
    ssh-keygen -t rsa
    ```
3. Output yoru id_rsa.pub key and copy it to your clipboard.
	```bash
    cat ~/.ssh/id_rsa.pub
    ```
4. [Add an SSH Key](https://cloud.digitalocean.com/settings/security) on DigitalOcean and name it '**Vagrant**'

### Download and Setup your environment for PostgreSQL
-----------------------
1. Change directory to where you would like to keep your vagrant files
For example:
    ```bash
    mkdir ~/Documents/vagrant
    cd ~/Documents/vagrant
    ```
2. Clone the [csci425 github repository](https://github.com/canance/csci425)
    ```bash
    git clone https://github.com/canance/csci425.git
    ```
3. Change directory to csci425/postgres
    ```bash 
    cd csci425/postgres
    ```
4. Vagrant up your environment
    ```bash
    vagrant up --provider=digital_ocean
    ```
