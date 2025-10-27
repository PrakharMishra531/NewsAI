import os
from groq import Groq
import os
from news_ai.core.config import GROQ_API_KEY, LLM_MODEL

try:
    groq_client = Groq(api_key=GROQ_API_KEY)
except Exception as e:
    print(f"Error initializing Groq client: {e}")
    print("Make sure you have set the GROQ_API_KEY environment variable.")
    exit()

def get_rag_answer(context, query):
    """
    Hands the context and query to the LLM for a final answer.
    """
    
    # 2. Build the prompt template
    # This is the "Augmentation" step.
    prompt_template = f"""
    Answer the following question based *only* on the provided context.
    If the answer is not in the context, say "I do not have this information."

    ---[CONTEXT]---
    {context}
    ---[END CONTEXT]---

    Question: {query}
    Answer:
    """
    
    print("--- [PROMPT SENT TO LLM] ---")
    print(prompt_template)
    print("----------------------------")
    
    try:
        # 3. Make the API call (The "Generation" step)
        chat_completion = groq_client.chat.completions.create(
            messages=[
                {
                    "role": "user",
                    "content": prompt_template,
                }
            ],
            model=LLM_MODEL,
            temperature=0.0, 
            max_tokens=500,
        )
        
        return chat_completion.choices[0].message.content

    except Exception as e:
        print(f"Error during Groq API call: {e}")
        return None
