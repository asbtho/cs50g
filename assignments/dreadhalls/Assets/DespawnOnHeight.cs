using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if ( transform.position.y < 0 ){
			Destroy(GameObject.Find("WhisperSource"));
			SceneManager.LoadScene("GameOver");
		}
	}
}
