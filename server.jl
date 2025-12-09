using HTTP, JSON3

const ROUTER = HTTP.Router()

function predict(req::HTTP.Request)
    data = JSON3.read(req.body)
    resp = Dict("習慣"=>round(rand()*0.1+0.4; digits=2), 
                "技術"=>round(rand()*0.1+0.4; digits=2), 
                "ビジネス"=>round(rand()*0.1+0.4; digits=2))
    return HTTP.Response(200, JSON3.write(resp))
end

HTTP.register!(ROUTER, "POST", "/predict", predict)

print("GrowthTrail AI Server starting on 0.0.0.0:10000...")
HTTP.serve(ROUTER, "0.0.0.0", 10000)
