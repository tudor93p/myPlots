import myLibs: ReadWrite, ComputeTasks

fn = x->"/media/tudor/Tudor/Work/2020_Snake-states/SnakeStates/Data/DeviceWithLeads/GreensFcts/075-37-2p000-0p030-2-0p005-0p00-0p400-0p400-0p002/AB/18-1-1p0-0p0-m1-1p00-m1p0-1p0/18-1-1p0-0p0-1-1p00-1p0-m1p0/$x"

obs = "QP-SiteVectorTransmission"


@show isfile(fn(obs))

Data = ReadWrite.Read_NamesVals(fn, obs, "jld")


@show typeof(Data)
P = Dict("obs_i"=>1)



#@time myPlots.Transforms.choose_obs_i(P, Data[obs], obs; f="sum") 


@time ComputeTasks.choose_obs_i(Data[obs]; P=P, f="sum")
@time ComputeTasks.choose_obs_i(Data[obs]; P=P, f="sum")

