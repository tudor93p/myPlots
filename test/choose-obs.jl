import myLibs: ReadWrite, ComputeTasks
import JLD 


fn(x) = joinpath("/media/tudor/Tudor/Work/2020_Snake-states/SnakeStates/Data/DeviceWithLeads/GreensFcts/060-30-0p001-0p030-2-0p71-0p005-0p00-0p400-0p400-0p002/AB/15-1-1p0-0p0-m1-1p00-m1p0-1p0/15-1-1p0-0p0-1-1p00-1p0-m1p0",x)


obs = "QP-SiteVectorTransmission"

@show fn(obs) 

@show readdir(fn(""))



@show isfile(fn(obs)*".jld")

Data = ReadWrite.Read_NamesVals(fn, obs, "jld")


@show typeof(Data)
P = Dict("obs_i"=>1)



@time myPlots.Transforms.choose_obs_i(P, Data[obs], obs; f="first") 
@time myPlots.Transforms.choose_obs_i(P, Data[obs], obs; f="first") 

SVOi,label = myPlots.Transforms.choose_obs_i(P, Data[obs], obs; f="first") 


@show size(SVOi) label 




@time ComputeTasks.choose_obs_i(Data[obs]; P=P, f="first")
@time ComputeTasks.choose_obs_i(Data[obs]; P=P, f="first")

