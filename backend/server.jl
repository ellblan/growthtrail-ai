using Pkg
Pkg.activate(@__DIR__)

using HTTP
using JSON

function cors_headers()
    return [
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Headers" => "Content-Type, Authorization",
        "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
        "Access-Control-Max-Age" => "86400"
    ]
end

function handle_options(req::HTTP.Request)
    return HTTP.Response(
        200,
        cors_headers(),
        ""   # body
    )
end

function extract_features(text::String)
    return [0.5, 0.3, 0.8]
end

function analyze(req::HTTP.Request)
    body = String(req.body)
    data = JSON.parse(body)
    text = data["text"]

    features = extract_features(text)

    response_body = JSON.json(Dict(
        "labels" => Dict(
            "positivity" => features[1],
            "abstractness" => features[2],
            "energy" => features[3]
        )
    ))

    return HTTP.Response(
        200,
        cors_headers(),
        response_body
    )
end

HTTP.serve("0.0.0.0", 8081) do req::HTTP.Request
    if req.method == "OPTIONS"
        return handle_options(req)
    elseif req.target == "/analyze" && req.method == "POST"
        return analyze(req)
    else
        return HTTP.Response(
            404,
            cors_headers(),
            "Not Found"
        )
    end
end
