using JSON
using Flux
using BSON: @save

data = JSON.parsefile("training_data.json")

X = [Float32[length(d["text"])] for d in data]
Y = [Float32[d["positivity"], d["energy"], d["stress"]] for d in data]

model = Chain(
    Dense(1, 8, relu),
    Dense(8, 3),
    σ
)

loss(model, x, y) = Flux.Losses.mse(model(x), y)

opt = Flux.setup(Adam(), model)

for epoch in 1:500
    for (x, y) in zip(X, Y)
        gs = gradient(model -> loss(model, x, y), model)
        Flux.update!(opt, model, gs)
    end
end

@save "model.bson" model
println("Model saved to model.bson")
