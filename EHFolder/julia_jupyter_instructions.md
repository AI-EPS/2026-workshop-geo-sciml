### Using Julia in Jupyter notebooks in the browser

Julia can be used in jupyter notebooks with the IJulia.jl package.
Open your computers terminal or powershell and navigate to your project folder and activate the Julia project with

```
julia --project=.
```

Add the IJulia.jl package with

```
] add IJulia
```

or

```
using Pkg
Pkg.add("IJulia")
```

Start the notebook with

```
using IJulia
notebook()
```

This opens the notebook in your default browser. The Julia environment in the notebook is the same project you used to open the notebook. Now you are ready to use Julia with jupyter!
