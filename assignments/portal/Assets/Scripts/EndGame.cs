using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class EndGame : MonoBehaviour {

	public Text WinText;
	public AudioSource WinAudio;

	// Use this for initialization
	void Start () {
		
	}

	void Awake() {
		WinText = GameObject.Find("WinningText").GetComponent<Text>();
		WinAudio = GameObject.Find("WinningSound").GetComponent<AudioSource>();
	}

	void OnTriggerEnter(){
		WinText.enabled = true;
		WinAudio.Play(0);
	}
	
	// Update is called once per frame
	void Update () {
		
	}
}
