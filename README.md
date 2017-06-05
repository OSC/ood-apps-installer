# Open OnDemand Apps Installer

![GitHub Release](https://img.shields.io/github/release/osc/ood-apps-installer.svg)
![GitHub License](https://img.shields.io/github/license/osc/ood-apps-installer.svg)

A utility that downloads and installs the latest stable releases of the Open
OnDemand system web applications. The following web applications are installed:

- [Dashboard App](https://github.com/OSC/ood-dashboard)
- [Shell App](https://github.com/OSC/ood-shell)
- [Files App](https://github.com/OSC/ood-fileexplorer)
- [File Editor App](https://github.com/OSC/ood-fileeditor)
- [Active Jobs App](https://github.com/OSC/ood-activejobs)
- [My Jobs App](https://github.com/OSC/ood-myjobs)

## Installation

From the command line you will clone down this project to a working directory:

```sh
scl enable git19 -- git clone https://github.com/OSC/ood-apps-installer.git apps
```

Go into this working directory:

```sh
cd apps
```

And then check out the latest stable release:

```sh
scl enable git19 -- git checkout v0.2.0
```

## Usage

First you will want to build the Open OnDemand web applications in a build
directory:

```sh
scl enable rh-ruby22 nodejs010 git19 -- rake
```

This will build all the web applications in the `build/` directory. You can
parallelize this process with:

```sh
scl enable rh-ruby22 nodejs010 git19 -- rake -mj [NUMBER]
```

where `NUMBER` is the number of apps to build in parallel.

> **Note**: You can add a default SSH host for the Shell App here by creating
> the file:
>
> ```
> build/shell/.env
> ```
>
> with the following contents:
>
> ```sh
> DEFAULT_SSHHOST="cluster.my_center.edu"
> ```

After a successful build and any modifications to the apps you make, you will
then want to install the apps to their system location at
`/var/www/ood/apps/sys` with:

```sh
sudo scl enable rh-ruby22 -- rake install
```

To install the apps in a different location you'd specify it through the
`PREFIX` environment variable as such:

```sh
sudo scl enable rh-ruby22 -- rake install PREFIX=/path/to/install/apps
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-apps-installer.
