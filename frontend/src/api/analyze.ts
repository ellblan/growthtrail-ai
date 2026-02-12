export type AnalyzeResponse = {
  labels: {
    positivity: number
    abstractness: number
    energy: number
  }
}

export type ConvertedSkill = {
  trait: string
  skill: string
  reason: string
  caveat?: string
}

export type ConvertTraitsResponse = {
  skills: ConvertedSkill[]
  not_found?: string[]
}

export async function analyzeText(text: string): Promise<AnalyzeResponse> {
  const res = await fetch("/analyze", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ text }),
  })

  if (!res.ok) {
    throw new Error("API error")
  }

  return res.json()
}

export async function convertTraits(traits: string[]): Promise<ConvertTraitsResponse> {
  const res = await fetch("/traits/convert", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ traits }),
  })

  if (!res.ok) {
    const error = await res.json().catch(() => ({ error: "API error" }))
    throw new Error(error.error || "API error")
  }

  return res.json()
}
