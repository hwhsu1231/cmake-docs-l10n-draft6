<h1>
Contributing Guidelines
</h1>

[Back to README](../README.md)

<details><summary><strong>Switch Languages</strong></summary>
<p></p>
<ul>
  <li><a href="./CONTRIBUTING.md"><code>en_US</code> : English</a></li>
  <li><a href="./CONTRIBUTING.ja_JP.md"><code>ja_JP</code> : 日本語</a></li>
  <li><a href="./CONTRIBUTING.ru_RU.md"><code>ru_RU</code> : Русский</a></li>
  <li><a href="./CONTRIBUTING.zh_CN.md"><code>zh_CN</code> : 简体中文</a></li>
  <li><a href="./CONTRIBUTING.zh_TW.md"><code>zh_TW</code> : 繁體中文</a></li>
</ul>
</details>

<h2 id="table-of-contents">
Table of Contents
</h2>

<ul>
  <li><a href="#writing-issues-commits-and-prs-in-english">Writing Issues, Commits, and PRs in English</a></li>
  <li><a href="#contributing-to-an-existing-translation">Contributing to an Existing Translation</a></li>
  <li><a href="#creating-a-new-language-translation">Creating a New Language Translation</a></li>
  <li><a href="#installing-the-prerequisites">Installing the Prerequisites</a>
    <ul>
      <li><a href="#on-ubuntu">On Ubuntu</a></li>
      <li><a href="#on-windows">On Windows</a></li>
      <li><a href="#on-macos">On macOS</a></li>
      <li><a href="#crowdin-cli">Crowdin CLI</a></li>
    </ul>
  </li>
  <li><a href="#building-the-documentation-locally">Building the Documentation Locally</a>
    <ul>
      <li><a href="#cloning-a-repository-and-its-submodules">Cloning a Repository and Its Submodules</a></li>
      <li><a href="#configuring-and-building-the-project">Configuring and Building the Project</a></li>
      <li><a href="#experiencing-the-version-switcher-locally">Experiencing the Version Switcher Locally</a></li>
    </ul>
  </li>
  <!-- <li><a href="#commit-messages-and-pr-titles">Commit Messages and PR Titles</a></li> -->
</ul>

<h2 id="writing-issues-commits-and-prs-in-english"><a href="#table-of-contents">
Writing Issues, Commits, and PRs in English
</a></h2>

Please write issues, commits, and pull requests in English, so that everyone can understand what you're talking about.

<h2 id="contributing-to-an-existing-translation"><a href="#table-of-contents">
Contributing to an Existing Translation
</a></h2>

<!-- If the language you plan to translate is already listed, you can simply follow the steps below: -->

There are two types of versions in this repository:

1. Crowdin version: Upload .pot files to Crowdin and then download .po files from Crowdin.
2. Gettext version: Versions other than those on Crowdin.

Translation order:

1. First complete the translation for the Crowdin version, then consider translating the Gettext version.
2. Translate the Gettext version from the highest to the lowest version (because CI/CD will automatically merge translations from higher versions to lower ones).

You can view the file at <code>.github/workflows/matrix.json</code>. In this file, the versions where <code>VERSION_COMPENDIUM</code> is empty are designated as Crowdin versions, whereas the versions where <code>VERSION_COMPENDIUM</code> is not empty are recognized as Gettext versions.

<h3 id="">For Crowdin Versions</h3>

1. <a href="https://accounts.crowdin.com/login">Log in</a> with your Crowdin account (<a href="https://accounts.crowdin.com/register">Sign up</a> if you don't have one).
2. Go to the Crowdin project and join it.
3. Choose the language you want to translate.

<h3 id="">For Gettext Versions</h3>

1. Fork a repository to your GitHub account.

Please complete the translation for the Crowdin version first, then contribute to translating the Gettext version.

Your inputs will update the translation file for your language.

> **NOTE**
> 
> Please translate directly on the Crowdin project. The GitHub repository will not accept any translation contributions for .po or .md files from forked repositories. Even if a pull request contributing a translation is successfully merged, it will be overwritten by translations downloaded later from the Crowdin project.


<h2 id="creating-a-new-language-translation"><a href="#table-of-contents">
Creating a New Language Translation
</a></h2>

You cannot directly create a new language in Crowdin by yourself, but you can request the creation of the language to the maintainer by submitting an issue in GitHub. Upon receiving the request, the maintainer will create the requested language in Crowdin and GitHub.

> **NOTE**
> 
> Please make sure your requested language is available in both Sphinx and Crowdin. You can check <a href="https://github.com/hwhsu1231/s2clm">here</a>.

<!-- For example:

```md
### Language Request

- Sphinx Code: `zh_CN`
- Crowdin Code: `zh-CN`
- Language Name: Simplified Chinese
- Localized Name: 简体中文
```

https://github.com/numpy/numpy/wiki/Translations-of-the-NumPy-website -->

<h2 id="installing-the-prerequisites"><a href="#table-of-contents">
Installing the Prerequisites
</a></h2>

<h3 id="on-ubuntu"><a href="#table-of-contents">
On Ubuntu
</a></h3>

1.  Install Git

    ```bash
    sudo apt install git
    ```

2.  Install CMake 3.23~latest

    ```bash
    sudo snap install cmake
    ```

    > **NOTE**
    > 
    > If you want to configure the project in <a href="https://code.visualstudio.com/">Visual Studio Code</a> with <a href="https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools">CMake Tools</a> extension, you might encounter the following error message with the Snap version of CMake:
    > 
    > ```
    > Bad CMake executable "/snap/bin/cmake".
    > ```
    >
    > You can solve this error by adopting the solution mentioned <a href="https://github.com/microsoft/vscode-cmake-tools/issues/838#issuecomment-1871993525">here</a>. That is:
    > 
    > ```bash
    > sudo ln -s /snap/cmake/current/bin/cmake /usr/bin/cmake
    > ```

3.  Install Python 3

    ```bash
    sudo apt install python3
    sudo apt install python3-pip
    sudo apt install python3-venv
    ```

4.  Install Gettext

    ```bash
    sudo apt install gettext
    ```

<h3 id="on-windows"><a href="#table-of-contents">
On Windows
</a></h3>

1.  Install Git

    * Method 1: Install it by archives or installers of <a href="https://gitforwindows.org/">Git-for-Windows</a> manually.

    * Method 2: Install it by Package Managers, such as <a href="https://learn.microsoft.com/en-us/windows/package-manager/winget/">Win-Get</a> or <a href="https://chocolatey.org/install">Chocolatey</a>.

      ```cmd
      :: Run one of the following commands
      winget install -e --id Git.Git
      choco install git.install
      choco install git.portable
      ```

2.  Install CMake 3.23~latest

    * Method 1: Install it by archives or installers of <a href="https://cmake.org/download/">CMake</a> manually.

    * Method 2: Install it by Package Managers, such as <a href="https://learn.microsoft.com/en-us/windows/package-manager/winget/">Win-Get</a> or <a href="https://chocolatey.org/install">Chocolatey</a>.

      ```cmd
      :: Run one of the following commands
      winget install -e --id Kitware.CMake
      choco install cmake
      choco install cmake.install
      choco install cmake.portable
      ```

3.  Install Python 3

    * Method 1: Install it by archives or installers of <a href="https://www.python.org/downloads/windows/">Python</a> manually.

    * Method 2: Install it by Package Packagers, such as <a href="https://learn.microsoft.com/en-us/windows/package-manager/winget/">Win-Get</a> or <a href="https://chocolatey.org/install">Chocolatey</a>.

      ```cmd
      :: Run one of the following commands
      winget install -e --id Python.Python.3 --scope machine
      choco install python3
      ```

4.  Install Gettext

    * Method 1: Install it by Nuget:

      ```powershell
      # Powershell
      nuget install Gettext.Tools -ExcludeVersion -OutputDirectory C:\nuget;
      Add-Content $env:GITHUB_PATH "C:\nuget\Gettext.Tools\tools\bin"
      ```

    * Method 2: Install it by archives or installers of <a href="https://mlocati.github.io/articles/gettext-iconv-windows.html">gettext-iconv-windows</a> manually.

<h3 id="on-macos"><a href="#table-of-contents">
On macOS
</a></h3>

1.  Install Git

    ```bash
    brew install git
    ```

2.  Install CMake 3.23~latest

    ```bash
    brew install cmake
    ```

3.  Install Python 3

    ```bash
    brew install python3
    ```

4.  Install Gettext

    ```bash
    brew install gettext
    ```

<h3 id="crowdin-cli"><a href="#table-of-contents">
Crowdin CLI
</a></h3>

This is only for maintainers. See <a href="https://crowdin.github.io/crowdin-cli/installation">Crowdin CLI Installation</a> for details.

<h2 id="building-the-documentation-locally"><a href="#table-of-contents">
Building the Documentation Locally
</a></h2>

<h3 id="cloning-a-repository-and-its-submodules"><a href="#table-of-contents">
Cloning the Repository and Its Submodules
</a></h3>

To clone a repository along with all of its submodules, you have two options available. Both methods ensure that you not only clone the main repository but also all associated submodules.

- <strong>Method 1:</strong> Using the `--recurse-submodules` Option

  This method allows you to clone the repository and all its submodules in a single command, which is the most straightforward and simplest way:

  ```bash
  git clone --recurse-submodules <git-remote-url>
  ```

  Replace `<git-remote-url>` with the repository's remote URL. Possible values are:

  ```
  https://github.com/hwhsu1231/cmake3-docs-l10n-draft2.git
  git://github.com/hwhsu1231/cmake3-docs-l10n-draft2.git
  https://github.com/<username>/cmake3-docs-l10n-draft2.git
  git://github.com/<username>/cmake3-docs-l10n-draft2.git
  ```

- <strong>Method 2:</strong> Manually Initializing Submodules

  If you have already cloned the repository but forgot to use the `--recurse-submodules` option, you can still manually initialize and update the submodules:

  1. First, clone the main repository:

      ```bash
      git clone <git-remote-url>
      ```

      Replace `<git-remote-url>` with your repository's remote URL.

  2. Next, switch to the repository's directory:

      ```bash
      cd <repo>
      ```

      Replace `<repo>` with your repository name.

  3. Finally, initialize and update the submodules:

      ```bash
      git submodule update --init --recursive
      ```

Choosing either of the above methods will achieve the same result, depending on your needs and preferences.

<h3 id="configuring-and-building-the-project"><a href="#table-of-contents">
Configuring and Building the Project
</a></h3>

If translators want to preview their translations locally (to ensure the translations contributed on Crowdin adhere to syntax)

* For building `zh_TW` language:

  1.  Configure with `zh_TW` preset:

      ```bash
      cmake --preset zh_TW
      ```

  2.  Build with `sphinx_build_docs` target:

      ```bash
      cmake --build out/build/zh_TW --target sphinx_build_docs
      ```

* For building `zh_CN` language:

  1.  Configure with `zh_CN` preset:

      ```bash
      cmake --preset zh_CN
      ```

  2.  Build with `sphinx_build_docs` target:

      ```bash
      cmake --build out/build/zh_CN --target sphinx_build_docs
      ```

* and so on.

<h3 id="experiencing-the-version-switcher-locally"><a href="#table-of-contents">
Experiencing the Version Switcher Locally
</a></h3>

To experience the version switcher locally, you simply need to set `BASEURL_HREF` to `file:///${sourceDir}/out/html` during configuration.

1.  You can create a `CMakeUserPresets.json` in the root directory and add a configure preset named `<locale>_local` inside it. Then, configure in the `cacheVariables` field:

    ```json
    {
      "version": 4,
      "configurePresets":[
        {
          "name": "zh_TW_local",
          "displayName": "Traditional Chinese (Local)",
          "description": "繁體中文 (Local)",
          "inherits": "zh_TW",
          "cacheVariables": {
            "BASEURL_HREF": "file:///${sourceDir}/out/html"
          }
        }
      ]
    }
    ```

2.  And then follow the steps mentioned before:

    1.  Configure with `zh_TW_local` preset:

        ```bash
        cmake --preset zh_TW_local
        ```

    2.  Build with `sphinx_build_docs` target

        ```bash
        cmake --build out/build/zh_TW_local --target sphinx_build_docs
        ```

<!-- <h2 id="commit-messages-and-pr-titles"><a href="#table-of-contents">
Commit Messages and PR Titles
</a></h2>

Any changes mainly related to the documentation of this repository should prepend `docs:` to its PR's title. For example:

```
docs: update documentation
docs: update README.md
docs: update docs/CONTRIBUTING.md
docs: update docs/MAINTAINING.md
docs: fix typo in README.md
docs: fix typo in docs/CONTRIBUTING.md
docs: fix typo in docs/MAINTAINING.md
docs: fix missing switch option in README.md
docs(license): update copyright year(s) 
```

Any changes mainly related to the CI/CD should preprend <code>ci:</code> to its PR's title. For example:

```
ci(gha): add concurrency for workflows
app(settins):
app(pull): 

```

Any changes mainly related to the source files (including cmake files) should prepend <code>feat:</code> or <code>fix:</code>. For example:

```
feat: add crowdin integration
feat: 
```

### 參考

https://github.com/python/peps/blob/main/CONTRIBUTING.rst -->