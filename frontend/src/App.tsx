import { useState } from "react"
import { analyzeText } from "./api/analyze"

function App() {
  const [text, setText] = useState("")
  const [result, setResult] = useState<any>(null)
  const [loading, setLoading] = useState(false)

  async function handleAnalyze() {
    if (!text.trim()) return
    setLoading(true)

    try {
      const data = await analyzeText(text)
      console.log("RESULT:", JSON.stringify(data, null, 2))
      setResult(data)
    } catch (e) {
      console.error("API error:", e)
      setResult({ error: "分析に失敗しました" })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div
      style={{
        padding: 20,
        maxWidth: 600,
        margin: "0 auto",
        fontFamily: "sans-serif",
      }}
    >
      <h1 style={{ textAlign: "center", marginBottom: 20 }}>GrowthTrail</h1>

      <textarea
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="文章を入力してください..."
        style={{
          width: "100%",
          height: 140,
          padding: 10,
          fontSize: 16,
          borderRadius: 6,
          border: "1px solid #ccc",
          resize: "vertical",
        }}
      />

      <button
        onClick={handleAnalyze}
        disabled={loading}
        style={{
          marginTop: 12,
          padding: "10px 20px",
          fontSize: 16,
          borderRadius: 6,
          border: "none",
          backgroundColor: loading ? "#aaa" : "#4CAF50",
          color: "white",
          cursor: loading ? "not-allowed" : "pointer",
          width: "100%",
        }}
      >
        {loading ? "分析中..." : "分析する"}
      </button>

      {result && (
        <div
          style={{
            marginTop: 20,
            padding: 15,
            backgroundColor: "#e5e5e5",
            borderRadius: 6,
            border: "1px solid #ddd",
            whiteSpace: "pre-wrap",
          }}
        >
          <strong style={{ color: "#333", display: "block", marginBottom: 10 }}>
            分析結果:
          </strong>
          <pre style={{
            marginTop: 10,
            fontSize: 16,
            lineHeight: "1.5em",
            color: "#333"
          }}>
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  )
}

export default App
