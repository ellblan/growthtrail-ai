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
    return HTTP.Response(200, cors_headers(), "")
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

    return HTTP.Response(200, cors_headers(), response_body)
end

function health_html(req::HTTP.Request)
    html_path = joinpath(@__DIR__, "frontend/dist/index.html")

    if !isfile(html_path)
        return HTTP.Response(500, "index.html not found in frontend/dist/")
    end

    html = read(html_path, String)
    return HTTP.Response(200, ["Content-Type" => "text/html"], html)
end

function static_file(req::HTTP.Request)
    rel_path = req.target[2:end] 
    file_path = joinpath(@__DIR__, "frontend/dist", rel_path)

    if !isfile(file_path)
        return nothing
    end

    content_type =
        endswith(file_path, ".js")  ? "application/javascript" :
        endswith(file_path, ".css") ? "text/css" :
        endswith(file_path, ".svg") ? "image/svg+xml" :
        endswith(file_path, ".png") ? "image/png" :
        "application/octet-stream"

    return HTTP.Response(200, ["Content-Type" => content_type], read(file_path))
end

HTTP.serve("0.0.0.0", 8081) do req::HTTP.Request

    if startswith(req.target, "/assets/")
        res = static_file(req)
        if res !== nothing
            return res
        end
    end

    if req.method == "OPTIONS"
        return handle_options(req)

    elseif req.target == "/health" && req.method == "GET"
        return health_html(req)

    elseif req.target == "/analyze" && req.method == "POST"
        return analyze(req)

    else
        return HTTP.Response(404, cors_headers(), "Not Found")
    end
end
