export type AnalyzeResponse = {
  labels: {
    positivity: number
    abstractness: number
    energy: number
  }
}

export async function analyzeText(text: string): Promise<AnalyzeResponse> {
  const res = await fetch("http://localhost:8081/analyze", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text }),
  })

  if (!res.ok) {
    throw new Error("API error")
  }

  return res.json()
}
