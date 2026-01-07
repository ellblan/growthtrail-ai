using HTTP
using JSON
using Gradio

# backend の URL
BACKEND_URL = "http://localhost:8081/analyze"

function analyze_text(text)
    try
        body = JSON.json(Dict("text" => text))
        res = HTTP.post(BACKEND_URL, ["Content-Type" => "application/json"], body)
        parsed = JSON.parse(String(res.body))

        labels = parsed["labels"]

        return """
        Positivity: $(labels["positivity"])
        Abstractness: $(labels["abstractness"])
        Energy: $(labels["energy"])
        """
    catch e
        return "Error: $e"
    end
end

demo = gradio_interface(
    analyze_text,
    "text",
    "text",
    title = "GrowthTrail Emotion Analyzer",
    description = "テキストを入力すると、感情スコアを返します。"
)

launch(demo, server_name="0.0.0.0", server_port=7860)
