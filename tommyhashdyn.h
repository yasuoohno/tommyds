/*
 * Copyright 2010 Andrea Mazzoleni. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY ANDREA MAZZOLENI AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL ANDREA MAZZOLENI OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/** \file
 * Dynamic chained hashtable.
 */

#ifndef __TOMMYHASHDYN_H
#define __TOMMYHASHDYN_H

#include "tommytypes.h"

/******************************************************************************/
/* hashdyn */

/** \internal
 * Initial and minimal size of the hashtable expressed as a power of 2.
 * The initial size is 2^TOMMY_HASHDYN_BIT.
 */
#define TOMMY_HASHDYN_BIT 4

/**
 * Dynamic hashtable node.
 * This is the node that you have to include inside your objects.
 */
typedef tommy_node tommy_hashdyn_node;

/**
 * Dynamic chained hashtable.
 *
 * This hashtable resizes dynamically. It starts with the minimal size of 16 buckets, it doubles
 * the size then it reaches a load factor greater than 0.5 and it halves the size with a load
 * factor lower than 0.125.
 *
 * All the elements are reallocated in a single resize operation done inside 
 * tommy_hashdyn_insert() or tommy_hashdyn_remove().
 *
 * Note that the resize operation takes approximatively 100 [ms] with 1 million of elements, 
 * and 1 [second] with 10 millions. This could be a problem in real-time applications.
 *
 * The resize also fragment the heap, as it involves allocating a double-sized table, copy elements, 
 * and deallocating the older table. Leaving a big hole in the heap.
 * 
 * The ::tommy_hashlin hashtable fixes both problems.
 */
typedef struct tommy_hashdyn_struct {
	tommy_hashdyn_node** bucket; /**< Hash buckets. One list for each hash modulus. */
	unsigned bucket_bit; /**< Bits used in the bit mask. */
	unsigned bucket_max; /**< Number of buckets. */
	unsigned bucket_mask; /**< Bit mask to access the buckets. */
	unsigned count; /**< Number of elements. */
} tommy_hashdyn;

/**
 * Initializes the hashtable.
 */
void tommy_hashdyn_init(tommy_hashdyn* hashdyn);

/**
 * Deinitializes the hashtable.
 */
void tommy_hashdyn_done(tommy_hashdyn* hashdyn);

/**
 * Inserts an element in the hashtable.
 */
void tommy_hashdyn_insert(tommy_hashdyn* hashdyn, tommy_hashdyn_node* node, void* data, tommy_hash_t hash);

/**
 * Searches and removes an element from the hashtable.
 * You have to provide a compare function and the hash of the element you want to remove.
 * If the element is not found, 0 is returned.
 * If more equal elements are present, the first one is removed.
 * This operation is faster than calling tommy_hashdyn_bucket() and tommy_hashdyn_remove_existing() separately.
 * \param cmp Compare function called with cmp_arg as first argument and with the element to compare as a second one.
 * The function should return 0 for equal elements, anything other for different elements.
 * \param cmp_arg Compare argument passed as first argument of the compare function.
 * \param hash Hash of the element to find and remove.
 * \return The removed element, or 0 if not found.
 */
void* tommy_hashdyn_remove(tommy_hashdyn* hashdyn, tommy_compare_func* cmp, const void* cmp_arg, tommy_hash_t hash);

/**
 * Gets the bucket of the specified hash.
 * The bucket is guaranteed to contain ALL the elements with the specified hash,
 * but it can contain also others.
 * You can access elements in the bucket following the ::next pointer until 0.
 * \param hash Hash of the element to find. 
 * \return The head of the bucket, or 0 if empty.
 */
tommy_inline tommy_hashdyn_node* tommy_hashdyn_bucket(tommy_hashdyn* hashdyn, tommy_hash_t hash)
{
	return hashdyn->bucket[hash & hashdyn->bucket_mask];
}

/**
 * Searches an element in the hashtable.
 * You have to provide a compare function and the hash of the element you want to find.
 * If more equal elements are present, the first one is returned.
 * \param cmp Compare function called with cmp_arg as first argument and with the element to compare as a second one.
 * The function should return 0 for equal elements, anything other for different elements.
 * \param cmp_arg Compare argument passed as first argument of the compare function.
 * \param hash Hash of the element to find.
 * \return The first element found, or 0 if none.
 */
tommy_inline void* tommy_hashdyn_search(tommy_hashdyn* hashdyn, tommy_compare_func* cmp, const void* cmp_arg, tommy_hash_t hash)
{
	tommy_hashdyn_node* i = tommy_hashdyn_bucket(hashdyn, hash);
	while (i) {
		/* we first check if the hash matches, as in the same bucket we may have multiples hash values */
		if (i->key == hash && cmp(cmp_arg, i->data) == 0)
			return i->data;
		i = i->next;
	}
	return 0;
}

/**
 * Removes an element from the hashtable.
 * You must already have the address of the element to remove.
 * \return The tommy_node::data field of the node removed.
 */
void* tommy_hashdyn_remove_existing(tommy_hashdyn* hashdyn, tommy_hashdyn_node* node);

/**
 * Gets the number of elements.
 */
tommy_inline unsigned tommy_hashdyn_count(tommy_hashdyn* hashdyn)
{
	return hashdyn->count;
}

/**
 * Gets the size of allocated memory.
 * It includes the size of the ::tommy_trie_node of the stored elements. 
 */
tommy_size_t tommy_hashdyn_memory_usage(tommy_hashdyn* hashdyn);

#endif
