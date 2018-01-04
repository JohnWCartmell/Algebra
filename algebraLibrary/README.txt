Reviewed 29 August 2017
=======================

algebra.module.xslt - has an entry point prepare_diamonds which tranforms a sequence of rewriteRule entities into a sequence of diamonds. This implements
                       unification of left hand sides of rewrite rules to check for confluence of the rules and highlights incompletnesses in the rewrite rules.
                       
sequence_enhancements.xslt - a module that is used from algebra.module.xslt and can probably be merged into it without loss.

rules2.initial_enrichment.module.xslt - enriches a set of rewrite rules with 'id', 'context' and 'xpath' 
                                        attributes subsequently these used 
                                       to generate transforms that implement the rules.

seqrules2xslt.xslt -  transforms a set of enriched rewrite rules into xslt templates that implement the rewrites.

rules2xslt         - transforms  a set of rewrite rules into xslt templates that implement the rewrites. 
                      This is an earlier version of seqrules2xslt.xslt before
                      it was found necessary to have the seq notation.
