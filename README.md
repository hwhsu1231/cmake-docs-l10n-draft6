<div align="center">
  <picture>
    <img width="100" height="100" src="docs/img/logo-cmake.svg">
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/img/logo-crowdin-white.svg">
    <source media="(prefers-color-scheme: light)" srcset="docs/img/logo-crowdin-dark.svg">
    <img width="100" height="100" src="docs/img/logo-crowdin-dark.svg">
  </picture>
</div>


<h1 id="localization-of-cmake-documentation">
Localization of CMake Documentation
</h1>

<details><summary><strong>Switch Languages</strong></summary>
<p></p>
<ul>
  <li><a href="./README.md"><code>en_US</code> : English</a></li>
  <li><a href="./README.ja_JP.md"><code>ja_JP</code> : 日本語</a></li>
  <li><a href="./README.ru_RU.md"><code>ru_RU</code> : Русский</a></li>
  <li><a href="./README.zh_CN.md"><code>zh_CN</code> : 简体中文</a></li>
  <li><a href="./README.zh_TW.md"><code>zh_TW</code> : 繁體中文</a></li>
</ul>
</details>

<h2 id="table-of-contents">
Table of Contents
</h2>

- <a href="#introduction">Introduction</a>
- <a href="#progress-of-translations">Progress of Translations</a>
- <a href="#preview-translations">Preview Translations</a>
  - <a href="#preview-in-local-build">Preview in Local Build</a>
  - <a href="#preview-in-gh-pages">Preview in GitHub Pages</a>
- <a href="#licenses">Licenses</a>
- <a href="#translation-disclaimer">Translation Disclaimer</a>
- <a href="#about-author">Maintainers List</a>
- <a href="#support-this-project">Support This Project</a>
- <a href="#sponsorship">Sponsorship</a>
- <a href="#contributors-list">Contributors List</a>
  - <a href="#code-contributors">Code Contributors</a>
  - <a href="#translation-contributors">Translation Contributors</a>
  - <a href="#financial-contributors">Financial Contributors</a>
- <a href="#acknowledgements">Acknowledgements</a>

<h2 id="introduction"><a href="#table-of-contents">
Introduction
</a></h2>

<div align="center">
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/stargazers" title="GitHub Stars" target="_blank"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/hwhsu1231/cmake-docs-l10n-draft6.svg?logo=github&style=flat&color=blue" ></a>
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/network/members" title="GitHub Forks" target="_blank"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/hwhsu1231/cmake-docs-l10n-draft6.svg?logo=github&style=flat&color=blue" ></a>
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/graphs/contributors" title="GitHub Contributors" target="_blank"><img alt="GitHub Contributors" src="https://img.shields.io/github/contributors/hwhsu1231/cmake-docs-l10n-draft6.svg?logo=github&style=flat&color=blue" ></a>
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6" title="GitHub Repo Size" target="_blank"><img alt="GitHub Repo Size" src="https://img.shields.io/github/repo-size/hwhsu1231/cmake-docs-l10n-draft6?logo=github&style=flat&color=blue"></a>
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/issues" title="GitHub Open Issues" target="_blank"><img alt="GitHub Open Issues" src="https://img.shields.io/github/issues/hwhsu1231/cmake-docs-l10n-draft6.svg?logo=github&style=flat&color=brightgreen" ></a>
  <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/pulls" title="GitHub Open Pull Requests" target="_blank"><img alt="GitHub Open Pull Requests" src="https://img.shields.io/github/issues-pr/hwhsu1231/cmake-docs-l10n-draft6?logo=github&style=flat&color=brightgreen" ></a><br />
  <a href="https://opensource.org/licenses/BSD-3-Clause" title="License: BSD-3-Clause" target="_blank"><img alt="License: BSD-3-Clause" src="https://img.shields.io/badge/License-BSD%203--Clause-blue.svg"></a>
  <a href="https://www.contributor-covenant.org/" title="Contributor Covenant: 2.1" target="_blank"><img alt="Contributor Covenant" src="https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg"></a>
  <a href="https://org-test.crowdin.com/cmake-docs" title="Crowdin Localized" target="_blank"><img alt="Crowdin Localized" src="https://badges.crowdin.net/cmake-docs-i18n/localized.svg" ></a>  
</div>
<p></p>

This is a localization project for CMake Documentation.

The translations are contributed in Crowdin Project and downloaded automatically in Git Repository.

Crowdin Project: https://org-test.crowdin.com/cmake-docs

Git Repository:

- GitHub (main): https://github.com/hwhsu1231/cmake-docs-l10n
- GitCode (mirror): https://gitcode.com/hwhsu1231/cmake-docs-l10n
- GitFlic (mirror): https://gitflic.ru/project/hwhsu1231/cmake-docs-l10n
- GitLab (mirror): https://gitlab.com/hwhsu1231/cmake-docs-l10n
- Gitee (mirror): https://gitee.com/hwhsu1231/cmake-docs-l10n
- Gitea (mirror): https://gitea.com/hwhsu1231/cmake-docs-l10n
- Codeberg (mirror): https://codeberg.org/hwhsu1231/cmake-docs-l10n

Contributing and Maintaining Guidelines:

- [Contributing Guidelines](./docs/CONTRIBUTING.md)
- [Maintaining Guidelines](./docs/MAINTAINING.md)

GitHub Worflows:

<p></p>
<table align="center">
  <tbody>
    <tr>
      <th>Status Badges</th>
      <th>Schedule</th>
      <th>Purpose</th>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-check-pr-status.yml"><img alt="ci-check-pr-status" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-check-pr-status.yml/badge.svg" ></a>
      </td>
      <td><strong>NONE</strong></td>
      <td>Check PR's status before merging.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-gettext-update-po.yml"><img alt="ci-gettext-update-po" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-gettext-update-po.yml/badge.svg" ></a>
      </td>
      <td><strong>NONE</strong></td>
      <td>Update po from Gettext.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-upload-pot.yml"><img alt="ci-crowdin-upload-pot" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-upload-pot.yml/badge.svg" ></a><br />
      </td>
      <td><strong>NONE</strong></td>
      <td>Upload pot to Crowdin.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-contributor.yml"><img alt="ci-crowdin-contributor" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-contributor.yml/badge.svg" ></a>
      </td>
      <td><strong>0 0 1,15 * *</strong></td>
      <td>Update Crowdin Contributors.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-document.yml"><img alt="ci-crowdin-document" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-document.yml/badge.svg" ></a>
      </td>
      <td><strong>0 0 1,15 * *</strong></td>
      <td>
        Upload documents to Crowdin;<br />
        Download documents from Crowdin.
      </td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-download-po.yml"><img alt="ci-crowdin-download-po" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-crowdin-download-po.yml/badge.svg" ></a>
      </td>
      <td><strong>0 0 1,15 * *</strong></td>
      <td>Download po from Crowdin.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-gettext-compend-po.yml"><img alt="ci-gettext-compend-po" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-gettext-compend-po.yml/badge.svg" ></a>
      </td>
      <td><strong>0 4 1,15 * *</strong></td>
      <td>Merge po with Compendium.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-deploy-gh-pages.yml"><img alt="ci-deploy-gh-pages" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-deploy-gh-pages.yml/badge.svg" ></a>
      </td>
      <td><strong>0 8 1,15 * *</strong></td>
      <td>Deploy html to GitHub Pages.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-deploy-po-version.yml"><img alt="ci-deploy-po-version" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-deploy-po-version.yml/badge.svg" ></a>
      </td>
      <td><strong>0 8 1,15 * *</strong></td>
      <td>Deploy po to <code>po/${VERSION}</code> branch.</td>
    </tr>
    <tr>
      <td>
        <a href="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-sphinx-update-pot.yml"><img alt="ci-sphinx-update-pot" src="https://github.com/hwhsu1231/cmake-docs-l10n-draft6/actions/workflows/ci-sphinx-update-pot.yml/badge.svg" ></a>
      </td>
      <td><strong>0 8 1,15 * *</strong></td>
      <td>Update pot from Sphinx.</td>
    </tr>
  </tbody>
</table>
