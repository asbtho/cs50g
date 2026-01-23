using UnityEngine;
using System.Collections;

public class GemSpawner : MonoBehaviour {

	public GameObject[] prefabs;

	// Use this for initialization
	void Start () {

		// infinite Gem spawning function, asynchronous
		StartCoroutine(SpawnGems());
	}

	// Update is called once per frame
	void Update () {

	}

	IEnumerator SpawnGems() {
		while (true) {

			// number of Gems we could spawn vertically
			int GemsThisRow = 1;

			// instantiate all Gems in this row separated by some random amount of space
			for (int i = 0; i < GemsThisRow; i++) {
				Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(26, Random.Range(-10, 10), 10), Quaternion.identity);
			}

			// pause 1-5 seconds until the next Gem spawns
			yield return new WaitForSeconds(Random.Range(10, 30));
		}
	}
}
