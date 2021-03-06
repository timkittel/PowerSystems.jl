using Logging
using PowerSystems

## Matpower files
files = readdir(abspath(joinpath(dirname(Base.find_package("PowerSystems")), "../data/matpower")))
file_ext = r".*?\.(\w+)"

if length(files) == 0
    @error "No test files in the folder"
end

for f in files
    @test try
        ext = match(file_ext, f)
        @info "Parsing $f ..."
        pm_dict = PowerSystems.parse_file(abspath(joinpath(dirname(Base.find_package("PowerSystems")), "../data/matpower",f)))
        @info "Successfully parsed $f to PowerModels dict"
        PowerSystems.make_mixed_units(pm_dict)
        @info "Successfully converted $f to mixed_units"
        ps_dict = PowerSystems.pm2ps_dict(pm_dict)
        @info "Successfully parsed $f to PowerSystems dict"
        Buses, Generators, Storages, Branches, Loads, LoadZones ,Shunts = PowerSystems.ps_dict2ps_struct(ps_dict)
        @info "Successfully parsed $f to PowerSystems devices"
        sys_test = PowerSystem(Buses, Generators,Loads,Branches,Storages,float(ps_dict["baseMVA"]))
        @info "Successfully parsed $f to PowerSystem struct"
        true
    catch
        @warn "error while parsing $f"
        false
    end
end