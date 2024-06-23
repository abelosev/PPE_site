'''
Exemple de l'utilisation :

python3 wordcl_rus.py <chemin vers le input> <chemin vers le output> --mask_path <chemin vers le mask>

En tant que fichier input le fichier contextes/compil_rus.txt a été utilisé. 

Le fichier image par default est mask.png
'''

import argparse
from wordcloud import WordCloud
from stop_words import get_stop_words
from PIL import Image
import re
import codecs
import numpy as np

def generate_wordcloud(input_path, output_path, mask_path='mask.png'):
    with codecs.open(input_path, encoding='utf-8', errors='ignore') as f:
        file = f.read().replace('\t', ' ').replace('\n', ' ')
        clean_text = re.sub(r'[^а-яА-Я]', ' ', file).lower()

    clean_text_suppl = re.sub(r'\b(ирони(и|ей|ю)|ольги|чернорицкой|котор(о|ы)м|поэтому|например|сарказм(а|у|е|ом))\b', '', clean_text)

    stopwords_ru = get_stop_words('russian')

    mask = np.array(Image.open(mask_path))

    wordcloud = WordCloud(background_color='white',
                          colormap='autumn',
                          collocations=False,
                          stopwords=stopwords_ru,
                          mask=mask).generate(clean_text_suppl)

    wordcloud.to_file(output_path)

def main():
    parser = argparse.ArgumentParser(description='Générer un wordcloud à partir d\'un fichier txt.')
    parser.add_argument('input_path', type=str, help='Chemin vers le input')
    parser.add_argument('output_path', type=str, help='Chemin vers le output')
    parser.add_argument('--mask_path', type=str, default='mask.png', help='Chemin vers le fichier image de masque')

    args = parser.parse_args()

    generate_wordcloud(args.input_path, args.output_path, args.mask_path)

if __name__ == '__main__':
    main()