import sys
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.worksheet.datavalidation import DataValidation
from openpyxl.comments import Comment

OUT = sys.argv[1]

FONT = "Arial"
BLUE = "0000FF"
GREEN = "008000"
YELLOW = PatternFill("solid", fgColor="FFFF00")
HEAD = PatternFill("solid", fgColor="E7EEF7")
thin = Side(style="thin", color="BFC7D5")
BOX = Border(left=thin, right=thin, top=thin, bottom=thin)

PCT = "0.0%"
PCT2 = "0.00%"
INT = "#,##0"
MULT = '0.00"x"'
DEC = "0.0"

wb = Workbook()


def f(bold=False, color="000000", size=10, italic=False):
    return Font(name=FONT, bold=bold, color=color, size=size, italic=italic)


def title(ws, text, sub=None):
    ws["A1"] = text
    ws["A1"].font = f(bold=True, size=14)
    if sub:
        ws["A2"] = sub
        ws["A2"].font = f(italic=True, color="555555")


def header(ws, row, labels, col=1):
    for i, lab in enumerate(labels):
        c = ws.cell(row=row, column=col + i, value=lab)
        c.font = f(bold=True)
        c.fill = HEAD
        c.border = BOX
        c.alignment = Alignment(wrap_text=True, vertical="center")


def put(ws, ref, value, fmt=None, kind="formula", key=False):
    c = ws[ref]
    c.value = value
    color = {"input": BLUE, "formula": "000000", "link": GREEN, "label": "000000"}[kind]
    c.font = f(color=color, bold=(kind == "label" and False))
    if fmt:
        c.number_format = fmt
    if key:
        c.fill = YELLOW
    c.border = BOX
    return c


def widths(ws, ws_widths):
    for col, w in ws_widths.items():
        ws.column_dimensions[col].width = w


# ---------------------------------------------------------------- Como usar
ws = wb.active
ws.title = "Como usar"
title(ws, "Rift Tamers — Planilha de balanceamento",
      "Ponto de partida dos números do GDD (23/11/2026). Mude as premissas e veja a curva se ajustar.")
rows = [
    ("Para que serve", "Calcula a renda por segundo dos monstros, a curva de progressão do MVP e o Ouro pedido em cada Ascensão."),
    ("", ""),
    ("Legenda", ""),
    ("Texto azul", "Valor para editar."),
    ("Fundo amarelo", "Alavanca principal: mexa nela primeiro."),
    ("Texto preto", "Fórmula. Não edite: ela recalcula sozinha."),
    ("Texto verde", "Valor puxado de outra aba."),
    ("", ""),
    ("Abas", ""),
    ("Premissas", "Todas as alavancas: raridade, tamanho, mutação, sorte, Toca, Ascensão e o Baú de Fenda. As somas de chance precisam dar 100%."),
    ("Renda", "Calculadora: escolha bioma, raridade, tamanho, mutação, estrelas, Fonte, Ascensão e passes de um monstro. As linhas que vêm preenchidas são exemplos."),
    ("Curva MVP", "Os 12 bosses do MVP em ordem, com o tempo-alvo entre um passo e outro e o custo em Ouro que esse tempo exige. Confere se a 1ª Ascensão cai entre 3 e 5 horas."),
    ("Ascensões", "Ouro sugerido para cada Ascensão a partir da renda estimada, comparado com o valor do GDD."),
    ("Combate", "As 12 fases do MVP: Poder recomendado, vida do boss, Ouro por vitória, o time que o jogador tem ao chegar e se o nível do time sugerido no LLD alcança o Poder recomendado."),
    ("", ""),
    ("Como os números saem", "Custo do próximo passo = renda total na Toca × tempo-alvo. Ou seja: você decide quanto tempo cada passo deve levar, e a planilha diz quanto ele deve custar."),
    ("Limitações", "A curva usa a média esperada de tamanho e mutação. Não conta duplicatas, estrelas nem a Fonte Mágica, então a renda real do jogador tende a ser um pouco maior: isso deixa a curva um pouco mais rápida, não mais lenta."),
]
for i, (a, b) in enumerate(rows, start=4):
    ws.cell(row=i, column=1, value=a).font = f(bold=bool(a))
    ws.cell(row=i, column=2, value=b).font = f()
    ws.cell(row=i, column=2).alignment = Alignment(wrap_text=True, vertical="top")
ws["A7"].font = f(bold=True, color=BLUE)
ws["A8"].fill = YELLOW
ws["A10"].font = f(bold=True, color=GREEN)
widths(ws, {"A": 22, "B": 110})

# ---------------------------------------------------------------- Premissas
p = wb.create_sheet("Premissas")
title(p, "Premissas", "Texto azul = editar. Fundo amarelo = alavanca principal. Fonte dos valores: GDD Rift Tamers.")

# Raridade A4:D12
header(p, 4, ["Raridade", "Renda base no bioma 1 (Ouro/s)", "Chance base de captura", "Aparece 1 em X partidas"])
rar = [("Comum", 5, 0.90, 1), ("Incomum", 12, 0.80, 1), ("Raro", 30, 0.65, 1), ("Épico", 80, 0.50, 1),
       ("Lendário", 250, 0.35, 1), ("Mítico", 1000, 0.20, 50), ("Divino", 5000, 0.10, 500), ("Secreto", 25000, 0.05, 10)]
for i, (n, b, c, x) in enumerate(rar, start=5):
    put(p, f"A{i}", n, kind="label")
    put(p, f"B{i}", b, INT, "input", key=True)
    put(p, f"C{i}", c, PCT, "input")
    put(p, f"D{i}", x, INT, "input")
p["D12"].comment = Comment("O Secreto só aparece depois de uma condição escondida (ex.: vencer o Pesadelo sem tomar dano). Depois dela, 1 em 10.", "GDD")

# Tamanho A14:C21
header(p, 14, ["Tamanho", "Multiplicador de renda", "Chance"])
tam = [("Mini", 0.8, 0.20), ("Normal", 1, 0.60), ("Grande", 1.5, 0.14), ("Gigante", 2, 0.05), ("Titânico", 3, 0.01)]
for i, (n, m, c) in enumerate(tam, start=15):
    put(p, f"A{i}", n, kind="label")
    put(p, f"B{i}", m, MULT, "input")
    put(p, f"C{i}", c, PCT, "input")
put(p, "A20", "Soma das chances (precisa dar 100%)", kind="label")
put(p, "C20", "=SUM(C15:C19)", PCT)
put(p, "D20", '=IF(ROUND(C20,6)=1,"OK","AJUSTE: não soma 100%")')
put(p, "A21", "Multiplicador médio esperado", kind="label")
put(p, "B21", "=SUMPRODUCT(B15:B19,C15:C19)", MULT)

# Mutação A23:D31
header(p, 23, ["Mutação", "Multiplicador de renda", "Chance", "Chance com Sorte+ ativa"])
mut = [("Nenhuma", 1, None), ("Dourado", 2, 0.05), ("Cristal", 3, 0.02), ("Arco-íris", 5, 0.005),
       ("Eclipse", 8, 0.001), ("Cósmico", 12, 0.0002)]
for i, (n, m, c) in enumerate(mut, start=24):
    put(p, f"A{i}", n, kind="label")
    put(p, f"B{i}", m, MULT, "input")
    if c is None:
        put(p, f"C{i}", "=1-SUM(C25:C29)", PCT2)
        put(p, f"D{i}", "=1-SUM(D25:D29)", PCT2)
    else:
        put(p, f"C{i}", c, PCT2, "input")
        put(p, f"D{i}", f"=C{i}*$B$35", PCT2)
put(p, "A30", "Soma das chances (precisa dar 100%)", kind="label")
put(p, "C30", "=SUM(C24:C29)", PCT2)
put(p, "D30", "=SUM(D24:D29)", PCT2)
put(p, "A31", "Multiplicador médio esperado", kind="label")
put(p, "B31", "=SUMPRODUCT(B24:B29,C24:C29)", MULT)
p["D23"].comment = Comment("A política do Roblox exige que a tela mostre estas chances reais enquanto a sorte estiver ativa.", "GDD")

# Alavancas gerais A33:B48
header(p, 33, ["Alavanca", "Valor"])
lev = [
    (34, "Multiplicador de renda por bioma", 10, MULT, True),
    (35, "Multiplicador de sorte do Sorte+ (nas mutações)", 1.5, MULT, False),
    (36, "Bônus de renda por estrela acima de 1", 0.10, PCT, False),
    (37, "Bônus de renda por nível da Fonte Mágica", 0.10, PCT, False),
    (38, "Renda de quem está no time (fração)", 0.25, PCT, False),
    (39, "Custo da 5ª vaga (Ouro)", 500, INT, False),
    (40, "Fator de custo de cada vaga seguinte", 3, MULT, False),
    (41, "Custo do nível 1 da Fonte Mágica (Ouro)", 1000, INT, False),
    (42, "Fator de custo de cada nível seguinte da Fonte", 4, MULT, False),
    (43, "Aumento do custo por nível de monstro", 0.25, PCT, False),
    (44, "Poder ganho por nível de monstro", 0.08, PCT, False),
    (45, "Vagas máximas na Toca (sem passe)", 12, INT, False),
    (46, "Multiplicador do passe Ouro x2", 2, MULT, False),
    (47, "Multiplicador do VIP", 1.1, MULT, False),
    (48, "Tempo-alvo juntando Ouro antes de cada Ascensão (min)", 30, INT, True),
]
for r, lab, v, fmt, key in lev:
    put(p, f"A{r}", lab, kind="label")
    put(p, f"B{r}", v, fmt, "input", key=key)

# Ascensão A50:D56
header(p, 50, ["Ascensão", "Multiplicador de renda", "Bônus de sorte", "Bioma do Rei exigido"])
asc = [("A0", 1, 0, None), ("A1", 2, 0.05, 2), ("A2", 4, 0.10, 3), ("A3", 8, 0.15, 4), ("A4", 16, 0.20, 5), ("A5", 32, 0.25, 6)]
for i, (n, m, s, b) in enumerate(asc, start=51):
    put(p, f"A{i}", n, kind="label")
    put(p, f"B{i}", m, MULT, "input", key=True)
    put(p, f"C{i}", s, PCT, "input")
    put(p, f"D{i}", b if b is not None else "—", INT if b else None, "input" if b else "label")

# Custos da Toca F4:H14
header(p, 4, ["Vaga", "Custo (Ouro)"], col=6)
for i, n in enumerate(range(5, 13), start=5):
    put(p, f"F{i}", n, kind="label")
    put(p, f"G{i}", f"=$B$39*$B$40^(F{i}-5)", INT)
header(p, 14, ["Nível da Fonte", "Custo (Ouro)", "Bônus de renda"], col=6)
for i, n in enumerate(range(1, 11), start=15):
    put(p, f"F{i}", n, kind="label")
    put(p, f"G{i}", f"=$B$41*$B$42^(F{i}-1)", INT)
    put(p, f"H{i}", f"=F{i}*$B$37", PCT)

# Baú de Fenda F27:H32
header(p, 27, ["Baú de Fenda (100 Gemas)", "Chance", ""], col=6)
bau = [("Épico", 0.60), ("Lendário", 0.30), ("Mítico", 0.09), ("Divino", 0.01)]
for i, (n, c) in enumerate(bau, start=28):
    put(p, f"F{i}", n, kind="label")
    put(p, f"G{i}", c, PCT, "input")
put(p, "F32", "Soma (precisa dar 100%)", kind="label")
put(p, "G32", "=SUM(G28:G31)", PCT)
put(p, "H32", '=IF(ROUND(G32,6)=1,"OK","AJUSTE: não soma 100%")')
p["F27"].comment = Comment("Item aleatório pago: o jogo precisa mostrar estas chances com um botão 'Detalhes' antes da compra.", "GDD")

# Papel F34:H37
header(p, 34, ["Papel", "Fator de Poder", "Fator de renda"], col=6)
for i, (n, fp, fr) in enumerate([("Lutador", 1.2, 0.8), ("Tesoureiro", 0.8, 1.2), ("Os dois", 1, 1)], start=35):
    put(p, f"F{i}", n, kind="label")
    put(p, f"G{i}", fp, MULT, "input")
    put(p, f"H{i}", fr, MULT, "input")
p["F34"].comment = Comment("Lutador tem mais Poder e menos renda; Tesoureiro, o contrário. Os Reis valem pelos dois.", "LLD")

# Poder base F39:G47
header(p, 39, ["Raridade", "Poder base no bioma 1"], col=6)
for i, (n, v) in enumerate([("Comum", 10), ("Incomum", 15), ("Raro", 25), ("Épico", 40), ("Lendário", 80),
                            ("Mítico", 120), ("Divino", 200), ("Secreto", 320)], start=40):
    put(p, f"F{i}", n, kind="label")
    put(p, f"G{i}", v, INT, "input")

# Combate F49:G56
header(p, 49, ["Combate", "Valor"], col=6)
for r_, lab, v, fmt, key in [
    (50, "Multiplicador de Poder por bioma", 5, MULT, False),
    (51, "Custo do nível 2 de um monstro (Ouro)", 200, INT, True),
    (52, "Vida do boss (x Poder recomendado)", 40, INT, False),
    (53, "Vida do Rei (x Poder recomendado)", 60, INT, False),
    (54, "Segundos de renda do boss no Ouro de cada vitória", 60, INT, False),
    (55, "Multiplicador do Poder recomendado no Difícil", 3, MULT, False),
    (56, "Multiplicador do Poder recomendado no Pesadelo", 9, MULT, False),
]:
    put(p, f"F{r_}", lab, kind="label")
    put(p, f"G{r_}", v, fmt, "input", key=key)

widths(p, {"A": 48, "B": 18, "C": 16, "D": 22, "E": 3, "F": 46, "G": 16, "H": 26})
p.freeze_panes = "A4"

# ---------------------------------------------------------------- Renda
r = wb.create_sheet("Renda")
title(r, "Calculadora de renda de um monstro",
      "As linhas preenchidas são exemplos. Troque os valores em azul; a renda é calculada nas colunas pretas.")
cols = ["Monstro", "Bioma (1 a 7)", "Raridade", "Tamanho", "Mutação", "Estrelas (1 a 5)",
        "Nível da Fonte (0 a 10)", "Ascensão", "Passe Ouro x2?", "VIP?", "Renda na Toca (Ouro/s)", "Renda no time (Ouro/s)"]
header(r, 4, cols)
ex = [
    ("Musguinho (exemplo)", 1, "Comum", "Normal", "Nenhuma", 1, 0, "A0", "Não", "Não"),
    ("Coruja Bruma (exemplo)", 1, "Épico", "Grande", "Dourado", 2, 3, "A0", "Não", "Não"),
    ("Esfinge Solarya (exemplo)", 2, "Lendário", "Gigante", "Cristal", 3, 6, "A1", "Sim", "Não"),
    ("Escorpião Prisma Alfa (exemplo)", 2, "Mítico", "Normal", "Arco-íris", 5, 10, "A1", "Sim", "Sim"),
]
last = 4 + 20
for i in range(5, last + 1):
    vals = ex[i - 5] if i - 5 < len(ex) else (None,) * 10
    for j, v in enumerate(vals):
        c = r.cell(row=i, column=j + 1, value=v)
        c.font = f(color=BLUE)
        c.border = BOX
    k = (f'=IF(OR(C{i}="",B{i}=""),"",'
         f'INDEX(Premissas!$B$5:$B$12,MATCH(C{i},Premissas!$A$5:$A$12,0))'
         f'*Premissas!$B$34^(B{i}-1)'
         f'*INDEX(Premissas!$B$15:$B$19,MATCH(D{i},Premissas!$A$15:$A$19,0))'
         f'*INDEX(Premissas!$B$24:$B$29,MATCH(E{i},Premissas!$A$24:$A$29,0))'
         f'*(1+Premissas!$B$36*(F{i}-1))'
         f'*(1+Premissas!$B$37*G{i})'
         f'*INDEX(Premissas!$B$51:$B$56,MATCH(H{i},Premissas!$A$51:$A$56,0))'
         f'*IF(I{i}="Sim",Premissas!$B$46,1)'
         f'*IF(J{i}="Sim",Premissas!$B$47,1))')
    put(r, f"K{i}", k, INT)
    put(r, f"L{i}", f'=IF(K{i}="","",K{i}*Premissas!$B$38)', INT)

lists = {
    "C": '"Comum,Incomum,Raro,Épico,Lendário,Mítico,Divino,Secreto"',
    "D": '"Mini,Normal,Grande,Gigante,Titânico"',
    "E": '"Nenhuma,Dourado,Cristal,Arco-íris,Eclipse,Cósmico"',
    "H": '"A0,A1,A2,A3,A4,A5"',
    "I": '"Sim,Não"',
    "J": '"Sim,Não"',
}
for col, formula in lists.items():
    dv = DataValidation(type="list", formula1=formula, allow_blank=True)
    r.add_data_validation(dv)
    dv.add(f"{col}5:{col}{last}")
for col, lo, hi in (("B", 1, 7), ("F", 1, 5), ("G", 0, 10)):
    dv = DataValidation(type="whole", operator="between", formula1=str(lo), formula2=str(hi), allow_blank=True)
    r.add_data_validation(dv)
    dv.add(f"{col}5:{col}{last}")
widths(r, {"A": 32, "B": 12, "C": 12, "D": 12, "E": 12, "F": 12, "G": 14, "H": 11, "I": 13, "J": 8, "K": 18, "L": 18})
r.freeze_panes = "B5"

# ---------------------------------------------------------------- Curva MVP
c = wb.create_sheet("Curva MVP")
title(c, "Curva de progressão do MVP",
      "Renda média esperada (tamanho e mutação médios). Mude o tempo-alvo em azul e veja quanto cada passo deve custar.")
header(c, 4, ["Passo", "Bioma", "Fenda", "Boss", "Raridade", "Renda do boss (Ouro/s)",
              "Renda total na Toca (Ouro/s)", "Tempo-alvo até o próximo passo (min)",
              "Custo do próximo passo (Ouro)", "Tempo acumulado (min)", "Papel"])
bosses = [
    (1, "1", "Musguinho", "Comum", 2, "Tesoureiro"), (1, "2", "Sapo-Lanterna", "Incomum", 3, "Lutador"),
    (1, "3", "Cogumestre", "Raro", 5, "Tesoureiro"), (1, "4", "Javali Raiz", "Épico", 8, "Lutador"),
    (1, "5", "Coruja Bruma", "Épico", 10, "Lutador"), (1, "Rei", "Ancião Carvalhorn", "Lendário", 15, "Os dois"),
    (2, "1", "Escarabrilho", "Comum", 15, "Tesoureiro"), (2, "2", "Lagartixa Brasa", "Incomum", 20, "Lutador"),
    (2, "3", "Cacto Tambor", "Raro", 25, "Tesoureiro"), (2, "4", "Escorpião Prisma", "Épico", 30, "Lutador"),
    (2, "5", "Djinn de Areia", "Épico", 35, "Lutador"), (2, "Rei", "Esfinge Solarya", "Lendário", 45, "Os dois"),
]
for i, (b, fen, name, rr, t, role) in enumerate(bosses, start=5):
    put(c, f"K{i}", role, kind="input")
    put(c, f"A{i}", i - 4, kind="label")
    put(c, f"B{i}", b, INT, "input")
    put(c, f"C{i}", fen, kind="label")
    put(c, f"D{i}", name, kind="label")
    put(c, f"E{i}", rr, kind="input")
    put(c, f"F{i}", f"=INDEX(Premissas!$B$5:$B$12,MATCH(E{i},Premissas!$A$5:$A$12,0))*INDEX(Premissas!$H$35:$H$37,MATCH(K{i},Premissas!$F$35:$F$37,0))*Premissas!$B$34^(B{i}-1)*Premissas!$B$21*Premissas!$B$31", INT)
    put(c, f"G{i}", f"=SUM($F$5:F{i})", INT)
    put(c, f"H{i}", t, INT, "input", key=True)
    put(c, f"I{i}", f"=G{i}*H{i}*60", INT)
    put(c, f"J{i}", f"=SUM($H$5:H{i})", INT)
c["I16"].comment = Comment("No último passo, este é o Ouro que o jogador junta durante o tempo-alvo do Rei das Dunas.", "GDD")

put(c, "A19", "Resumo da 1ª Ascensão", kind="label")
c["A19"].font = f(bold=True)
summary = [
    (20, "Tempo jogando até vencer o Rei das Dunas (h)", "=J16/60", DEC),
    (21, "Tempo extra juntando Ouro para ascender (min)", "=Premissas!$B$48", INT),
    (22, "Tempo total até a 1ª Ascensão (h)", "=(J16+D21)/60", DEC),
    (23, "Meta do GDD: entre 3 e 5 horas", '=IF(AND(D22>=3,D22<=5),"Dentro da meta","Fora da meta: ajuste os tempos-alvo")', None),
    (24, "Ouro sugerido para a 1ª Ascensão", "='Ascensões'!G5", INT),
]
for row, lab, fm, fmt in summary:
    c.merge_cells(f"A{row}:C{row}")
    c[f"A{row}"] = lab
    c[f"A{row}"].font = f()
    cell = put(c, f"D{row}", fm, fmt, "link" if "!" in fm else "formula")
widths(c, {"A": 8, "B": 8, "C": 8, "D": 22, "E": 12, "F": 16, "G": 18, "H": 18, "I": 20, "J": 16, "K": 13})
c.freeze_panes = "A5"

# ---------------------------------------------------------------- Ascensões
a = wb.create_sheet("Ascensões")
title(a, "Ouro pedido em cada Ascensão",
      "Sugestão = renda estimada no Rei exigido × tempo-alvo juntando Ouro. Compare com o valor do GDD.")
header(a, 4, ["Ascensão", "Bioma do Rei exigido", "Multiplicador antes de ascender",
              "Renda dos 12 melhores monstros (Ouro/s)", "Tempo-alvo juntando Ouro (min)",
              "Ouro do GDD", "Ouro sugerido", "GDD ÷ sugerido", "Leitura"])
gdd = [10_000_000, 200_000_000, 5_000_000_000, 100_000_000_000, 2_000_000_000_000]
for i, lvl in enumerate(range(1, 6), start=5):
    put(a, f"A{i}", f"A{lvl}", kind="label")
    put(a, f"B{i}", f"=INDEX(Premissas!$D$51:$D$56,MATCH(A{i},Premissas!$A$51:$A$56,0))", INT, "link")
    put(a, f"C{i}", f"=INDEX(Premissas!$B$51:$B$56,{lvl})", MULT, "link")
    base_sum = ("(Premissas!$B$5*Premissas!$H$36+Premissas!$B$6*Premissas!$H$35+Premissas!$B$7*Premissas!$H$36"
                "+2*Premissas!$B$8*Premissas!$H$35+Premissas!$B$9*Premissas!$H$37)")
    put(a, f"D{i}", f"={base_sum}*Premissas!$B$34^(B{i}-1)*(1+1/Premissas!$B$34)*Premissas!$B$21*Premissas!$B$31*C{i}", INT)
    put(a, f"E{i}", "=Premissas!$B$48", INT, "link")
    put(a, f"F{i}", gdd[i - 5], INT, "input")
    put(a, f"G{i}", f"=D{i}*E{i}*60", INT)
    put(a, f"H{i}", f"=IF(G{i}=0,0,F{i}/G{i})", MULT)
    put(a, f"I{i}", f'=IF(H{i}<0.5,"GDD pede pouco",IF(H{i}>2,"GDD pede demais","OK"))')
a["D4"].comment = Comment("Os 12 melhores monstros = os 6 bosses do bioma do Rei + os 6 do bioma anterior (10x menos renda), com tamanho e mutação médios e o fator de papel de cada boss (Tesoureiro, Lutador ou os dois).", "GDD")
widths(a, {"A": 11, "B": 14, "C": 16, "D": 22, "E": 16, "F": 22, "G": 22, "H": 14, "I": 18})
a.freeze_panes = "A5"

# ---------------------------------------------------------------- Combate
cb = wb.create_sheet("Combate")
title(cb, "Combate: as 12 fases do MVP",
      "Poder recomendado em azul com fundo amarelo. Time e nível em azul vêm do LLD (aba Fases 1 a 12); o resto é calculado.")
header(cb, 4, ["Fase", "Boss", "Tipo", "Bioma", "Raridade", "Papel", "Poder base do boss", "Renda base do boss (Ouro/s)",
               "Poder recomendado (Normal)", "Difícil", "Pesadelo", "Vida do boss", "Ouro por vitória (Normal)",
               "Melhores monstros ao chegar (Poder base)", "Soma de Poder base do time", "Nível médio do time (LLD)",
               "Poder do time nesse nível", "Poder do time ÷ recomendado", "Leitura",
               "Ouro para treinar 1 monstro do nível 1 até esse nível"])
fases = [
    ("Musguinho", "Fenda", 1, "Comum", "Tesoureiro", 10, "Inicial 12", 12, 1),
    ("Sapo-Lanterna", "Fenda", 1, "Incomum", "Lutador", 25, "Inicial 12 + Musguinho 8", 20, 3),
    ("Cogumestre", "Fenda", 1, "Raro", "Tesoureiro", 50, "Sapo-Lanterna 18 + Inicial 12 + Musguinho 8", 38, 5),
    ("Javali Raiz", "Fenda", 1, "Épico", "Lutador", 80, "Cogumestre 20 + Sapo-Lanterna 18 + Inicial 12", 50, 9),
    ("Coruja Bruma", "Fenda", 1, "Épico", "Lutador", 180, "Javali Raiz 48 + Cogumestre 20 + Sapo-Lanterna 18", 86, 15),
    ("Ancião Carvalhorn", "Rei", 1, "Lendário", "Os dois", 270, "Javali Raiz 48 + Coruja Bruma 48 + Cogumestre 20", 116, 18),
    ("Escarabrilho", "Fenda", 2, "Comum", "Tesoureiro", 500, "Carvalhorn 80 + Inicial 60 + Javali Raiz 48", 188, 23),
    ("Lagartixa Brasa", "Fenda", 2, "Incomum", "Lutador", 550, "Carvalhorn 80 + Inicial 60 + Javali Raiz 48", 188, 26),
    ("Cacto Tambor", "Fenda", 2, "Raro", "Tesoureiro", 700, "Lagartixa Brasa 90 + Carvalhorn 80 + Inicial 60", 230, 28),
    ("Escorpião Prisma", "Fenda", 2, "Épico", "Lutador", 900, "Cacto Tambor 100 + Lagartixa Brasa 90 + Carvalhorn 80", 270, 30),
    ("Djinn de Areia", "Fenda", 2, "Épico", "Lutador", 1500, "Escorpião Prisma 240 + Cacto Tambor 100 + Lagartixa Brasa 90", 430, 33),
    ("Esfinge Solarya", "Rei", 2, "Lendário", "Os dois", 2200, "Escorpião Prisma 240 + Djinn de Areia 240 + Cacto Tambor 100", 580, 36),
]
for i, (name, tipo, bio, rar, role, pr, team_txt, team, lvl) in enumerate(fases, start=5):
    put(cb, f"A{i}", i - 4, kind="label")
    put(cb, f"B{i}", name, kind="label")
    put(cb, f"C{i}", tipo, kind="input")
    put(cb, f"D{i}", bio, INT, "input")
    put(cb, f"E{i}", rar, kind="input")
    put(cb, f"F{i}", role, kind="input")
    put(cb, f"G{i}", f"=INDEX(Premissas!$G$40:$G$47,MATCH(E{i},Premissas!$F$40:$F$47,0))"
                     f"*INDEX(Premissas!$G$35:$G$37,MATCH(F{i},Premissas!$F$35:$F$37,0))*Premissas!$G$50^(D{i}-1)", INT)
    put(cb, f"H{i}", f"=INDEX(Premissas!$B$5:$B$12,MATCH(E{i},Premissas!$A$5:$A$12,0))"
                     f"*INDEX(Premissas!$H$35:$H$37,MATCH(F{i},Premissas!$F$35:$F$37,0))*Premissas!$B$34^(D{i}-1)", DEC)
    put(cb, f"I{i}", pr, INT, "input", key=True)
    put(cb, f"J{i}", f"=I{i}*Premissas!$G$55", INT)
    put(cb, f"K{i}", f"=I{i}*Premissas!$G$56", INT)
    put(cb, f"L{i}", f'=I{i}*IF(C{i}="Rei",Premissas!$G$53,Premissas!$G$52)', INT)
    put(cb, f"M{i}", f"=H{i}*Premissas!$G$54", INT)
    put(cb, f"N{i}", team_txt, kind="input")
    put(cb, f"O{i}", team, INT, "input")
    put(cb, f"P{i}", lvl, INT, "input")
    put(cb, f"Q{i}", f"=O{i}*(1+Premissas!$B$44*(P{i}-1))", INT)
    put(cb, f"R{i}", f"=IF(I{i}=0,0,Q{i}/I{i})", PCT)
    put(cb, f"S{i}", f'=IF(R{i}>=1,"Pronto",IF(R{i}>=0.9,"Quase: vence jogando bem","Precisa treinar mais"))')
    put(cb, f"T{i}", f"=Premissas!$G$51*((1+Premissas!$B$43)^(P{i}-1)-1)/Premissas!$B$43", INT)
cb["N4"].comment = Comment("Os 3 monstros com mais Poder base que o jogador tem ao chegar na fase. O monstro inicial vale 12 no Bosque e 60 depois de abrir as Dunas.", "LLD")
cb["Q4"].comment = Comment("Poder do time = soma do Poder dos 3 monstros. Cada nível acima do 1 soma 8% do Poder base (Premissas B44).", "LLD")
cb["T4"].comment = Comment("Custo somado do nível 1 até o nível da coluna P, para um monstro. Um monstro recém-capturado começa no nível 1.", "LLD")
put(cb, "A18", "Regras", kind="label")
cb["A18"].font = f(bold=True)
notes = [
    "Vida do time = 10 × Poder do time. O dano dos inimigos é uma fração da vida de referência (10 × Poder recomendado).",
    "Se o Poder do time passar de 3 × o recomendado da dificuldade escolhida, o loot cai pela metade (anti-farm).",
    "Difícil dá 1,5x de loot e Pesadelo dá 2,25x. Os dois usam o Poder recomendado multiplicado por Premissas G55 e G56.",
]
for k, txt in enumerate(notes, start=19):
    cb[f"A{k}"] = txt
    cb[f"A{k}"].font = f()
widths(cb, {"A": 6, "B": 20, "C": 8, "D": 7, "E": 11, "F": 12, "G": 12, "H": 14, "I": 14, "J": 10, "K": 11,
            "L": 12, "M": 14, "N": 52, "O": 13, "P": 12, "Q": 13, "R": 14, "S": 24, "T": 20})
cb.freeze_panes = "C5"

for sheet in wb.worksheets:
    sheet.sheet_view.showGridLines = True
    for row in sheet.iter_rows():
        for cell in row:
            if cell.font is None or cell.font.name != FONT:
                cell.font = Font(name=FONT, size=cell.font.size if cell.font else 10,
                                 bold=cell.font.bold if cell.font else False,
                                 color=cell.font.color if cell.font else None)

wb.save(OUT)
print("saved", OUT)
