extends RefCounted
## Rotinas leves por dia. Nenhum processamento por quadro.
## Pontos de trabalho e descanso ficam na via central, fora das casas.
const POSTS := {
    "doran": {"work": Vector3(-4.1, 0, -9), "rest": Vector3(-2.5, 0, 6), "job": "Trabalhando na forja"},
    "kael": {"work": Vector3(2.2, 0, -22), "rest": Vector3(0, 0, 9), "job": "Vigiando a estrada"},
    "mercador_marcial": {"work": Vector3(2.2, 0, -6), "rest": Vector3(2.2, 0, -6), "job":"Negociando equipamentos de cavaleiro"},
    "mercador_arcano": {"work": Vector3(-3.2, 0, -17), "rest": Vector3(-3.2, 0, -17), "job":"Vendendo equipamentos arcanos"},
    "mercador_sagrado": {"work": Vector3(2.5, 0, 3.5), "rest": Vector3(2.5, 0, 3.5), "job":"Vendendo reliquias de sacerdotes"},
    "iris_feirante": {"work": Vector3(3.2, 0, 8), "rest": Vector3(1.0, 0, 19), "job": "Vendendo mercadorias"},
    "bento_agricultor": {"work": Vector3(-18, 0, 22), "rest": Vector3(-3.0, 0, 18), "job": "Cuidando da plantacao"},
    "elira": {"work": Vector3(2.2, 0, -12), "rest": Vector3(-2.4, 0, 6), "job": "Treinando"},
    "mira": {"work": Vector3(-3.1, 0, -4), "rest": Vector3(0.0, 0, 16), "job": "Cuidando dos doentes"},
    "lia_moradora": {"work": Vector3(2.8, 0, 13), "rest": Vector3(-2.5, 0, 20), "job": "Cuidando da casa"},
    "selene": {"work": Vector3(2.6, 0, -5), "rest": Vector3(-2.0, 0, 15), "job": "Estudando as rotas"},
}
static func position_for(npc_id: String, day: int) -> Vector3:
    var post: Dictionary = POSTS.get(npc_id, {})
    if post.is_empty():
        return Vector3(3.0, 0, float((absi(hash(npc_id)) % 7) * 5) - 15.0)
    return post["work"] if day % 3 != 0 else post["rest"]

static func activity_for(npc_id: String, day: int) -> String:
    var post: Dictionary = POSTS.get(npc_id, {})
    if post.is_empty():
        return "Passeando pela cidade"
    return str(post["job"]) if day % 3 != 0 else "Descansando"

static func has_post(npc_id: String) -> bool:
    return POSTS.has(npc_id)
