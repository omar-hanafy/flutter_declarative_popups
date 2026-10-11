# Repository setup

The release pipeline uses pull requests to `main` for stable versions and to
`dev` for prereleases. A version change merged into either lane creates the tag
`flutter_declarative_popups-v<version>`, a GitHub release, and a tag-triggered
publication to pub.dev. Dependency-only edits keep the existing version and do
not create another tag. GitHub release notes come from the matching reviewed
changelog section. The workflow rejects a missing, empty, duplicate, or
author-mentioning section before creating a tag.

## Protect the release lanes

Configure branch protection or rulesets for each active release lane:

- Require pull requests, passing checks, and resolved review conversations.
- Prevent force pushes and deletion, and enforce the policy for administrators.
- Preserve any existing review, code-owner, signature, deployment, and bypass rules.

Use check contexts from a successful PR when configuring required checks. The
workflows define stable formatting/analysis/tests, minimum Flutter
analysis/tests, Pana, and publication dry-run jobs. The beta job is advisory.
Do not configure example build or PR-title checks unless workflows actually
provide them.

Before enabling `dev`, create it through the repository's permitted process,
ensure its `pubspec.yaml` version has a prerelease suffix, and protect the lane.
The lane check runs on every PR targeting `main` or `dev` and on every push to
those lanes, even when `pubspec.yaml` is unchanged.

## Configure tag authentication

Store a repository-scoped fine-grained GitHub PAT as the Actions secret
`TAG_PUSH_PAT`. It needs Contents read/write access to this repository and must
be permitted by the repository's release-tag ruleset.

The auto-release job uses this identity to push the release tag. A tag pushed
with `GITHUB_TOKEN` would not trigger the publication workflow. The PAT is used
only for the tag push; the GitHub release uses the job's `GITHUB_TOKEN`.

Protect `flutter_declarative_popups-v*` tags according to the repository's
release policy. Published versions and release tags are immutable.

## Configure pub.dev Trusted Publisher

For an existing package, open the
[package admin page](https://pub.dev/packages/flutter_declarative_popups/admin)
and enable automated publishing from GitHub Actions with:

- Repository: `omar-hanafy/flutter_declarative_popups`
- Tag pattern: `flutter_declarative_popups-v{{version}}`

The publication workflow calls the official
`dart-lang/setup-dart/.github/workflows/publish.yml@v1` reusable workflow and
requests an OIDC token. pub.dev accepts this path only for tag-push events.
Do not add branch or manual triggers to `publish.yml`.

If an environment is required on pub.dev, configure that same environment in
GitHub and pass its name to the reusable workflow. Otherwise leave it unset.
A package's first version must be published manually by an authorized uploader
before automated publishing can be enabled.

See [Dart's automated publishing documentation](https://dart.dev/tools/pub/automated-publishing).

## Local and hosted checks

Use Flutter 3.47.7 or newer, including Dart 3.13.5 or newer. CI checks the latest
stable SDK and separately resolves the lowest allowed dependencies on Flutter
3.47.7. Beta analysis/tests provide early compatibility feedback.

Prepare the intended version and changelog on a working branch, then run:

```bash
bash scripts/release.sh main # stable release PR
# Or, for a prerelease PR:
bash scripts/release.sh dev
```

This runs dependency resolution, check-only formatting, analysis, tests,
publication dry-run, and Pana 0.23.19 with its full-score exit threshold. The
publication checks require the reviewed changes to be committed so that the
publication payload is clean. The script does not commit, push, tag, or publish.

For changes to popup behavior or example navigation, also run the example's
app integration checks with `cd example && flutter test integration_test -d macos`.
These exercise a running app; the root widget tests run separately.

After merging the release PR, correlate the Auto release run with its merged
SHA, confirm the tag targets that SHA, and watch the Publish to pub.dev run for
that exact tag. Finally verify that pub.dev exposes the intended version.
A passing local check or GitHub release alone does not prove publication.

## Failure recovery

Read the failing run's logs before changing anything. Confirm the PAT has not
expired, the Trusted Publisher repository/tag pattern matches, and the run was
triggered by the exact release tag.

Keep a failed tag unchanged. Repair the cause, choose a new version, and release
through another PR. Do not delete, move, or reuse a release tag, bypass warnings,
or publish directly from a protected branch.
