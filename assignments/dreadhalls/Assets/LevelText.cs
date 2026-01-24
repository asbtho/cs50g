using UnityEngine;
using UnityEngine.UI;
using System.Collections;

[RequireComponent(typeof(Text))]
public class LevelText : MonoBehaviour {

	private Text text;
	private static int levelNumber;

	// Use this for initialization
	void Start () {
		text = GetComponent<Text>();
	}
	
	// Update is called once per frame
	void Update () {
		text.text = "Level: " + levelNumber;
	}

	public void increaseLevel() {
		levelNumber++;
		return;
	}

	public void resetLevel() {
		levelNumber = 0;
		return;
	}
}
