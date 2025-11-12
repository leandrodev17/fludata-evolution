import { Logger } from '../../config/logger.config';

const logger = new Logger('GeminiTranscriptionService');

export class GeminiTranscriptionService {
  private readonly apiKey: string;
  private readonly modelName = 'gemini-2.0-flash-lite';
  private readonly baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY || '';

    if (!this.apiKey) {
      logger.warn('GEMINI_API_KEY não configurada. Transcrição de áudio desabilitada.');
    }
  }

  /**
   * Transcreve um áudio em Base64 (.ogg) usando a API REST do Gemini
   * @param audioBase64 String Base64 do áudio
   * @returns Texto transcrito ou null em caso de erro
   */
  async transcribeAudio(audioBase64: string): Promise<string | null> {
    if (!this.apiKey) {
      logger.error('GEMINI_API_KEY não configurada');
      return null;
    }

    try {
      const url = `${this.baseUrl}/${this.modelName}:generateContent?key=${this.apiKey}`;

      const payload = {
        contents: [
          {
            parts: [
              {
                inlineData: {
                  data: audioBase64,
                  mimeType: 'audio/ogg',
                },
              },
              {
                text: 'Transcreva o arquivo de áudio OGG fornecido com a máxima fidelidade. Garanta que a pontuação esteja correta e quebras de parágrafo sejam usadas quando houver mudanças claras de falante ou de tópico. Não adicione comentários, introduções ou conclusões; entregue APENAS o texto transcrito.',
              },
            ],
          },
        ],
      };

      logger.verbose('Enviando áudio para transcrição Gemini');

      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        const errorText = await response.text();
        logger.error(`Erro na API Gemini (${response.status}): ${errorText}`);
        return null;
      }

      const jsonResponse = await response.json();
      const transcription = jsonResponse?.candidates?.[0]?.content?.parts?.[0]?.text;

      if (!transcription) {
        logger.error('Erro ao extrair transcrição da resposta do Gemini');
        return null;
      }

      logger.verbose('Áudio transcrito com sucesso');
      return transcription;
    } catch (error) {
      logger.error(`Erro ao transcrever áudio: ${error.message}`);
      return null;
    }
  }

  /**
   * Verifica se o serviço está habilitado
   */
  isEnabled(): boolean {
    return !!this.apiKey && process.env.GEMINI_ENABLED === 'true';
  }
}
