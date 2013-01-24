import numpy
import re
import nltk
import sys
from sklearn.feature_extraction.text import CountVectorizer
import pickle
import os
from itertools import chain
import copy
import operator
import logging
import math
from feature_extractor import FeatureExtractor

base_path = os.path.dirname(__file__)
sys.path.append(base_path)
from essay_set import EssaySet
import util_functions

if not base_path.endswith("/"):
    base_path=base_path+"/"

log = logging.getLogger(__name__)


class PredictorExtractor(object):
    def __init__(self):
        self._extractors = []

    def initialize_dictionaries(self, p_set):
        success = False
        if not (hasattr(p_set, '_type')):
            error_message = "needs to be an essay set of the train type."
            log.exception(error_message)
            raise util_functions.InputError(p_set, error_message)

        if not (p_set._type == "train"):
            error_message = "needs to be an essay set of the train type."
            log.exception(error_message)
            raise util_functions.InputError(p_set, error_message)

        max_feats2 = math.floor(200/len(p_set._essay_sets))
        for i in xrange(0,len(p_set._essay_sets)):
            self._extractors.append(FeatureExtractor())
            self._extractors[i].initialize_dictionaries(p_set._essay_sets[i], max_feats2=max_feats2)

        return success

    def gen_feats(self, p_set):
        
