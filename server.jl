using HTTP, JSON3, Flux 

const GROWTH_MODEL = Chain(
    Dense(3, 8, relu),
    Dense(8, 3),
    softmax
)

const ROUTER = HTTP.Router()

function predict(req::HTTP.Request)
    data = JSON3.read(req.body)
    inputs = Float32[data["習慣"], data["技術"], data["ビジネス"]]
    
    predictions = GROWTH_MODEL(inputs)
    
    resp = Dict(
        "習慣成長"   => round(predictions[1], digits=2),
        "技術成長"   => round(predictions[2], digits=2),
        "ビジネス成長" => round(predictions[3], digits=2)
    )
    return HTTP.Response(200, JSON3.write(resp))
end

function health(req::HTTP.Request)
    body = JSON3.write(Dict("status" => "ok"))
    return HTTP.Response(200, body)
end

HTTP.register!(ROUTER, "POST", "/predict", predict)
HTTP.register!(ROUTER, "GET",  "/health",  health)

print("GrowthTrail AI Server starting on 0.0.0.0:10000...")
HTTP.serve(ROUTER, "0.0.0.0", 10000)
