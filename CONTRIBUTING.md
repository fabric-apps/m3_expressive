# Contributing

Contributions are welcome. Please read this document before opening a pull request.

## Reporting issues

Use the GitHub issue tracker. For bugs, include the Flutter version
(`flutter --version`), the package version, a minimal reproduction, and
the full stack trace if one is present.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Make your changes. If you are adding a new component, add a demo to the
   `example/` app.
3. Run `flutter analyze` and `flutter test` and resolve any issues.
4. Open a pull request with a clear description of what changed and why.

## Code style

This project follows the rules in `analysis_options.yaml`, which extends
`package:flutter_lints`. No force-pushes to `main`.

## Scope

This package is limited to visual components directly related to the
Material 3 Expressive design language as specified by Google. Feature
requests outside that scope are unlikely to be accepted.
