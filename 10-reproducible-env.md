# Reproducible Julia Environments

This demo uses the current directory as the project environment. That means `Project.toml` and `Manifest.toml` will be created in the folder where you run the commands.

## 1. Start in the REPL

Open a terminal in your project folder and start Julia:

```powershell
julia
```

Then enter Pkg mode by pressing `]`.

You should see a prompt like this:

```text
(@v1.11) pkg>
```

Activate the current directory:

```text
(@v1.11) pkg> activate .
```

Now the current folder is your project environment. If `Project.toml` and `Manifest.toml` do not exist yet, Julia will create them here as needed.

## 2. Add Plots in the REPL

Still in Pkg mode, add Plots:

```text
(current-folder) pkg> add Plots
```

After this finishes:

- `Project.toml` contains `Plots` in `[deps]`
- `Manifest.toml` is created or updated
- the exact resolved dependency graph is stored in the manifest

Back in your editor, inspect the two files manually.

## 3. Inspect `Project.toml`

Open `Project.toml` manually in your editor.

You should see something like:

```toml
[deps]
Plots = "..."
```

Julia will fill in the real UUID automatically. The key point is that `Project.toml` records the direct dependency you asked for.

## 4. Inspect `Manifest.toml`

Now open `Manifest.toml` manually in your editor.

This file is much longer. It records the exact versions Julia selected for Plots and every package Plots depends on.

That is the reproducible snapshot.

## 5. Remove Plots and inspect again

Go back to Julia Pkg mode and remove Plots:

```text
(current-folder) pkg> rm Plots
```

Now inspect the files again manually in your editor.

After removal:

- `Plots` disappears from `Project.toml`
- `Manifest.toml` is rewritten to match the new environment

This is the cleanest way to see that the environment is just the current folder plus those TOML files.

## 6. Add another dependency later

Stay in Julia, enter Pkg mode again with `]`, and add `Statistics`:

```text
(current-folder) pkg> add Statistics
```

Then inspect `Project.toml` manually again.

Now `Statistics` is recorded as part of the current project's dependencies.

## 7. Edit the environment by editing `Project.toml`

Sometimes you want to edit the environment by hand, usually to add compatibility bounds.

For example, you might change `Project.toml` to include:

```toml
[compat]
Plots = "1.40"
julia = "1.10"
```

After editing `Project.toml`, go back to Pkg mode and run:

```text
(current-folder) pkg> resolve
```

That updates `Manifest.toml` so it matches the edited project file.

## 8. Rebuild the same environment later

If you return to the project later, or someone else clones it, start Julia in that folder, enter Pkg mode, and run:

```text
(@v1.11) pkg> activate .
(current-folder) pkg> instantiate
(current-folder) pkg> precompile
```

## 9. Main idea

Julia separates:

- what you want in `Project.toml`
- what Julia actually resolved in `Manifest.toml`

When you run `Pkg.activate(".")`, both files belong to the current directory, so the environment travels with the project.