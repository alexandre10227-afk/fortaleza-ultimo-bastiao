extends RefCounted
## Original narrative. Inspired by the themes of costly defense and independent
## characters, never by copying dialogue or proper nouns from existing works.
const AUDIENCE_OPENING := "A coroa pede vidas todos os invernos. No norte, chamam isso de dever. Na fronteira, chamam de perda. Diga-me: o que vale uma muralha se ninguem restar para viver atras dela?"
const AUDIENCE_QUESTION := "Nao me importa se voce nasceu nobre. Preciso saber o que fara quando a escolha for entre salvar um soldado ferido e manter fechado o unico portao."
const AUDIENCE_CHOICES := [
    "Abro o portao. Nenhuma vida sera descartada sem tentar.",
    "Mantenho a linha. Uma decisao pode salvar centenas."
]
const AUDIENCE_RESPONSE := [
    "O rei observa voce em silencio. 'Compaixao exige coragem. Mas prepare-se: os que morrerem por sua escolha nao serao apenas numeros.'",
    "O rei abaixa os olhos. 'Comando exige firmeza. Mas lembre-se dos nomes que ficarem do lado de fora.'"
]
const OATH_QUESTION := "Ainda assim, os ataques chegarao em intervalos de cinco dias. Aceita o encargo da fortaleza e conquista seu lugar, ou recusa minha coroa e segue seu proprio caminho?"
const OATH_CHOICES := [
    "Aceito. Protegerei a fortaleza, mas conquistarei minha autoridade.",
    "Recuso. Nao darei minha vida por uma ordem que nao escolhi."
]
const OATH_ENDING_GUARD := "O rei entrega uma ordem lacrada, sem titulo nem terras. 'Nao lhe dei um trono. Dei-lhe um lugar onde suas escolhas terao peso. Va e descubra quanto custa cumprir uma promessa.'"
const OATH_ENDING_EXILE := "A sala fica imovel. 'Entao a fronteira sera defendida por Vaelor, nosso melhor general. Voce partira para Porto Cinzento. La ninguem devera lhe obediencia, e os moradores da fortaleza nao esquecerao sua recusa.'"

static func npc_line(npc_id: String, oath: String, quest_status: String, memory_count: int) -> String:
    match npc_id:
        "doran":
            if oath == "exile":
                return "Vieram aqui pedir minha ajuda, mas quando as fogueiras acenderem sera meu filho quem ficara junto a muralha. Voce pode partir. Ele nao."
            if quest_status == "complete":
                return "O ferro que trouxe ja esta na muralha. Ainda assim, minha filha me perguntou se metal pode impedir o medo. Nao soube responder."
            if memory_count > 0:
                return "Voltou. Isso conta mais do que imagina. Os viajantes prometem tudo antes da primeira noite de frio."
            return "A forja nunca descansa. Cada prego segura uma porta, e atras de cada porta ha uma familia que nao sabe lutar."
        "elira":
            if oath == "exile":
                return "O rei chamou sua escolha de covardia? Eu ja vi comandantes que escondiam o medo atras de um brasao. Aqui, suas acoes dirao quem voce e."
            if quest_status == "complete":
                return "As ervas ajudaram, mas os doentes continuam chegando. Uma caravana inteira desapareceu perto da estrada do lago."
            if memory_count > 0:
                return "Voce voltou. Pensei que fosse mais um rosto perdido na estrada. Talvez eu tenha julgado cedo demais."
            return "Um contrato vale pouco quando o pagamento chega e os amigos nao. Aprendi isso longe daqui."
        "mira":
            if memory_count > 0:
                return "Lembro de voce. As noticias correm rapido, mas as feridas demoram. Sente-se e diga o que aconteceu."
            return "Nao pergunto de que lado lutaram. Quando entram pela minha porta, todos sangram da mesma cor."
        "kael":
            if oath == "exile":
                return "O general Vaelor assumiu a defesa. Diga-me: quando a estrada trouxer refugiados, voce abrira a porta para eles?"
            return "Estive nas torres ao amanhecer. As criaturas estao aprendendo nossos caminhos. Precisamos aprender os delas."
        _:
            return "Cada viajante carrega uma historia, e nenhuma delas termina ao sair desta cidade."

## Dilemas originais, independentes das obras usadas como referencia visual.
const TOWN_DILEMMAS := {
    "doran": {
        "question": "As ferramentas da forja servem para reforcar o portao, mas tambem para reparar as casas queimadas. O ferro e pouco. Para onde enviaremos o primeiro lote?",
        "choices": ["Primeiro as casas. Os moradores precisam de abrigo.", "Primeiro a muralha. Sem defesa, todos perderao suas casas."],
        "answers": [
            "Doran respira fundo. 'Minha filha dormira sob um teto melhor. Nao esquecerei esta decisao.'",
            "Doran assente. 'Tomara que a muralha resista. Vou lembrar quem assumiu essa responsabilidade.'"
        ],
        "region": "Fortaleza"
    },
    "elira": {
        "question": "Uma barcaca de refugiados chegou sem moedas. Os capitães querem expulsá-los, e os mercadores temem perder os suprimentos. Qual e sua ordem?",
        "choices": ["Permitir o desembarque e organizar abrigo provisório.", "Exigir que trabalhem antes de receber suprimentos."],
        "answers": [
            "Elira observa a praia. 'Talvez voce ainda possa provar que poder significa responsabilidade.'",
            "Elira franze o cenho. 'Trabalho em troca de comida. Espero que saiba o peso desta escolha.'"
        ],
        "region": "Porto Cinzento"
    }
}
